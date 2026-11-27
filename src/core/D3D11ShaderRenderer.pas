unit D3D11ShaderRenderer;

interface

uses
  Winapi.Windows, Winapi.D3D11, Winapi.DXGI, Winapi.DxgiFormat, Winapi.D3DCommon, Winapi.D3DCompiler,
  System.SysUtils, System.Classes, System.SyncObjs, System.IOUtils, System.Math, System.RegularExpressions,
  LibVLC, Lut3D;

type
  TGPUShaderFlag = (gsAnime4K, gsCAS, gsDeband, gsACES, gsCRT, gsLevels16_235, gsBT601to709, gsLut3D);
  TGPUShaderFlags = set of TGPUShaderFlag;

  TShaderCBuffer = packed record
    TexSizeX: Single;
    TexSizeY: Single;
    InvTexX: Single;
    InvTexY: Single;
    Flags: Cardinal;
    LutEnabled: Cardinal;
    LutSize: Single;
    TimeSec: Single;
  end;

  TD3D11ShaderRenderer = class
  private
    FHwnd: HWND;
    FWidth: Cardinal;
    FHeight: Cardinal;
    FDevice: ID3D11Device;
    FContext: ID3D11DeviceContext;
    FSwapChain: IDXGISwapChain;
    FRTV: ID3D11RenderTargetView;
    FVideoTex: ID3D11Texture2D;
    FVideoSRV: ID3D11ShaderResourceView;
    FLutTex: ID3D11Texture3D;
    FLutSRV: ID3D11ShaderResourceView;
    FVertexShader: ID3D11VertexShader;
    FPixelShader: ID3D11PixelShader;
    FDefaultPS: ID3D11PixelShader;
    FSampler: ID3D11SamplerState;
    FCB: ID3D11Buffer;
    FFlags: TGPUShaderFlags;
    FLutSize: Integer;
    FFrameBuf: TBytes;
    FLock: TCriticalSection;
    FInitialized: Boolean;
    FStartTick: UInt64;
    function CompileBuiltinShaders(out ErrorMsg: string): Boolean;
    procedure EnsureVideoTexture(W, H: Cardinal);
    procedure RecreateRenderTarget(W, H: Cardinal);
  public
    constructor Create;
    destructor Destroy; override;
    function Initialize(AHwnd: HWND; AWidth, AHeight: Cardinal; out ErrorMsg: string): Boolean;
    procedure Resize(AWidth, AHeight: Cardinal);
    function UploadLut3D(const ALut: TLut3DProfile; out ErrorMsg: string): Boolean;
    function LoadCustomHLSL(const AFilePath: string; out ErrorMsg: string): Boolean;
    procedure ResetCustomHLSL;
    procedure RenderFrame(const Data: Pointer; Pitch, W, H: Cardinal);
    procedure AttachToPlayer(Player: Plibvlc_media_player_t);
    procedure ReleaseDevice;
    property Initialized: Boolean read FInitialized;
    property Flags: TGPUShaderFlags read FFlags write FFlags;
    property VideoWidth: Cardinal read FWidth;
    property VideoHeight: Cardinal read FHeight;
  end;

implementation

const
  BuiltinHLSL =
    'cbuffer Params : register(b0) {' + #10 +
    '  float4 TexInfo;' + #10 + // x=W, y=H, z=1/W, w=1/H
    '  uint Flags;' + #10 +
    '  uint LutEnabled;' + #10 +
    '  float LutSize;' + #10 +
    '  float TimeSec;' + #10 +
    '};' + #10 +
    'Texture2D VideoTex : register(t0);' + #10 +
    'Texture3D LutTex : register(t1);' + #10 +
    'SamplerState LinearSampler : register(s0);' + #10 +
    'struct VSOut { float4 pos : SV_POSITION; float2 uv : TEXCOORD0; };' + #10 +
    'VSOut VSMain(uint id : SV_VertexID) {' + #10 +
    '  VSOut o;' + #10 +
    '  o.uv = float2((id << 1) & 2, id & 2);' + #10 +
    '  o.pos = float4(o.uv * float2(2, -2) + float2(-1, 1), 0, 1);' + #10 +
    '  return o;' + #10 +
    '}' + #10 +
    'float Luma(float3 c) { return dot(c, float3(0.2126, 0.7152, 0.0722)); }' + #10 +
    'float4 PSMain(VSOut i) : SV_TARGET {' + #10 +
    '  float2 px = TexInfo.zw;' + #10 +
    '  float3 c = VideoTex.Sample(LinearSampler, i.uv).rgb;' + #10 +
    '  if ((Flags & 1) != 0) {' + #10 + // gsAnime4K: Sobel edge-aware line sharpen
    '    float3 tl = VideoTex.Sample(LinearSampler, i.uv + float2(-px.x, -px.y)).rgb;' + #10 +
    '    float3 t  = VideoTex.Sample(LinearSampler, i.uv + float2(0, -px.y)).rgb;' + #10 +
    '    float3 tr = VideoTex.Sample(LinearSampler, i.uv + float2(px.x, -px.y)).rgb;' + #10 +
    '    float3 l  = VideoTex.Sample(LinearSampler, i.uv + float2(-px.x, 0)).rgb;' + #10 +
    '    float3 r  = VideoTex.Sample(LinearSampler, i.uv + float2(px.x, 0)).rgb;' + #10 +
    '    float3 bl = VideoTex.Sample(LinearSampler, i.uv + float2(-px.x, px.y)).rgb;' + #10 +
    '    float3 b  = VideoTex.Sample(LinearSampler, i.uv + float2(0, px.y)).rgb;' + #10 +
    '    float3 br = VideoTex.Sample(LinearSampler, i.uv + float2(px.x, px.y)).rgb;' + #10 +
    '    float gx = Luma(tr + 2*r + br) - Luma(tl + 2*l + bl);' + #10 +
    '    float gy = Luma(bl + 2*b + br) - Luma(tl + 2*t + tr);' + #10 +
    '    float edge = saturate(sqrt(gx*gx + gy*gy) * 1.8);' + #10 +
    '    float3 blur = (t + b + l + r) * 0.25;' + #10 +
    '    c = saturate(c + (c - blur) * (0.45 + 0.85 * edge));' + #10 +
    '  }' + #10 +
    '  if ((Flags & 2) != 0) {' + #10 + // gsCAS: Contrast Adaptive Sharpen
    '    float3 t = VideoTex.Sample(LinearSampler, i.uv + float2(0, -px.y)).rgb;' + #10 +
    '    float3 b = VideoTex.Sample(LinearSampler, i.uv + float2(0, px.y)).rgb;' + #10 +
    '    float3 l = VideoTex.Sample(LinearSampler, i.uv + float2(-px.x, 0)).rgb;' + #10 +
    '    float3 r = VideoTex.Sample(LinearSampler, i.uv + float2(px.x, 0)).rgb;' + #10 +
    '    float3 mn = min(c, min(min(t, b), min(l, r)));' + #10 +
    '    float3 mx = max(c, max(max(t, b), max(l, r)));' + #10 +
    '    float3 amp = saturate(min(mn, 1.0 - mx) / max(mx, 1e-4)) * 0.35;' + #10 +
    '    c = saturate(c + (c - (t + b + l + r) * 0.25) * amp * 2.2);' + #10 +
    '  }' + #10 +
    '  if ((Flags & 4) != 0) {' + #10 + // gsDeband: Ordered 4x4 dither
    '    float2 p = floor(i.uv * TexInfo.xy);' + #10 +
    '    float d = frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453) - 0.5;' + #10 +
    '    c = saturate(c + d * (1.5 / 255.0));' + #10 +
    '  }' + #10 +
    '  if ((Flags & 8) != 0) {' + #10 + // gsACES: Filmic HDR->SDR Tone Mapping
    '    float3 x = c * 1.15;' + #10 +
    '    c = saturate((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14));' + #10 +
    '  }' + #10 +
    '  if ((Flags & 16) != 0) {' + #10 + // gsCRT: Scanlines
    '    float scan = 0.88 + 0.12 * sin(i.uv.y * TexInfo.y * 3.14159265);' + #10 +
    '    c *= scan;' + #10 +
    '  }' + #10 +
    '  if ((Flags & 32) != 0) {' + #10 + // gsLevels16_235: TV (16-235) -> PC (0-255)
    '    c = saturate((c - (16.0 / 255.0)) * (255.0 / 219.0));' + #10 +
    '  }' + #10 +
    '  if ((Flags & 64) != 0) {' + #10 + // gsBT601to709: Color Matrix
    '    float3 r709;' + #10 +
    '    r709.r = dot(c, float3(1.0440, -0.0440, 0.0000));' + #10 +
    '    r709.g = dot(c, float3(0.0000,  0.9648, 0.0352));' + #10 +
    '    r709.b = dot(c, float3(0.0000,  0.0095, 0.9905));' + #10 +
    '    c = saturate(r709);' + #10 +
    '  }' + #10 +
    '  if ((LutEnabled != 0) && (LutSize >= 2.0)) {' + #10 + // Real 3D LUT Texture3D
    '    float3 uvw = (saturate(c) * (LutSize - 1.0) + 0.5) / LutSize;' + #10 +
    '    c = LutTex.Sample(LinearSampler, uvw).rgb;' + #10 +
    '  }' + #10 +
    '  return float4(c, 1.0);' + #10 +
    '}';

function VlcLockCB(Opaque: Pointer; Planes: PPointer): Pointer; cdecl;
var
  Renderer: TD3D11ShaderRenderer;
begin
  Renderer := TD3D11ShaderRenderer(Opaque);
  Renderer.FLock.Enter;
  if Length(Renderer.FFrameBuf) > 0 then
    Planes^ := @Renderer.FFrameBuf[0]
  else
    Planes^ := nil;
  Result := nil;
end;

procedure VlcUnlockCB(Opaque, Picture: Pointer; const Planes: PPointer); cdecl;
var
  Renderer: TD3D11ShaderRenderer;
begin
  Renderer := TD3D11ShaderRenderer(Opaque);
  Renderer.FLock.Leave;
end;

procedure VlcDisplayCB(Opaque, Picture: Pointer); cdecl;
var
  Renderer: TD3D11ShaderRenderer;
begin
  Renderer := TD3D11ShaderRenderer(Opaque);
  Renderer.FLock.Enter;
  try
    if Length(Renderer.FFrameBuf) > 0 then
      Renderer.RenderFrame(@Renderer.FFrameBuf[0], Renderer.FWidth * 4, Renderer.FWidth, Renderer.FHeight);
  finally
    Renderer.FLock.Leave;
  end;
end;

function VlcFormatCB(Opaque: PPointer; Chroma: PAnsiChar; Width, Height, Pitches, Lines: PCardinal): Cardinal; cdecl;
var
  Renderer: TD3D11ShaderRenderer;
begin
  Renderer := TD3D11ShaderRenderer(Opaque^);
  if (Width^ = 0) or (Height^ = 0) then
  begin
    Width^ := 1280;
    Height^ := 720;
  end;
  Move(AnsiString('RV32')[1], Chroma^, 4);
  Pitches^ := Width^ * 4;
  Lines^ := Height^;

  Renderer.FLock.Enter;
  try
    Renderer.EnsureVideoTexture(Width^, Height^);
    SetLength(Renderer.FFrameBuf, Width^ * Height^ * 4);
  finally
    Renderer.FLock.Leave;
  end;
  Result := 1;
end;

constructor TD3D11ShaderRenderer.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FStartTick := GetTickCount64;
  FFlags := [];
end;

destructor TD3D11ShaderRenderer.Destroy;
begin
  ReleaseDevice;
  FreeAndNil(FLock);
  inherited Destroy;
end;

procedure TD3D11ShaderRenderer.ReleaseDevice;
begin
  FLock.Enter;
  try
    FInitialized := False;
    FRTV := nil;
    FVideoSRV := nil;
    FVideoTex := nil;
    FLutSRV := nil;
    FLutTex := nil;
    FPixelShader := nil;
    FDefaultPS := nil;
    FVertexShader := nil;
    FSampler := nil;
    FCB := nil;
    FSwapChain := nil;
    FContext := nil;
    FDevice := nil;
    SetLength(FFrameBuf, 0);
  finally
    FLock.Leave;
  end;
end;

function TD3D11ShaderRenderer.CompileBuiltinShaders(out ErrorMsg: string): Boolean;
var
  VSBlob, PSBlob, ErrBlob: ID3DBlob;
  HR: HRESULT;
  Src: AnsiString;
begin
  Result := False;
  ErrorMsg := '';
  Src := AnsiString(BuiltinHLSL);

  HR := D3DCompile(PAnsiChar(Src), Length(Src), 'VLCModernBuiltin.hlsl', nil, nil,
    'VSMain', 'vs_4_0', 0, 0, VSBlob, ErrBlob);
  if Failed(HR) then
  begin
    if ErrBlob <> nil then ErrorMsg := string(PAnsiChar(ErrBlob.GetBufferPointer))
    else ErrorMsg := Format('VS compile failed: 0x%.8x', [HR]);
    Exit;
  end;

  HR := FDevice.CreateVertexShader(VSBlob.GetBufferPointer, VSBlob.GetBufferSize, nil, @FVertexShader);
  if Failed(HR) then
  begin
    ErrorMsg := Format('CreateVertexShader failed: 0x%.8x', [HR]);
    Exit;
  end;

  ErrBlob := nil;
  HR := D3DCompile(PAnsiChar(Src), Length(Src), 'VLCModernBuiltin.hlsl', nil, nil,
    'PSMain', 'ps_4_0', 0, 0, PSBlob, ErrBlob);
  if Failed(HR) then
  begin
    if ErrBlob <> nil then ErrorMsg := string(PAnsiChar(ErrBlob.GetBufferPointer))
    else ErrorMsg := Format('PS compile failed: 0x%.8x', [HR]);
    Exit;
  end;

  HR := FDevice.CreatePixelShader(PSBlob.GetBufferPointer, PSBlob.GetBufferSize, nil, FDefaultPS);
  if Failed(HR) then
  begin
    ErrorMsg := Format('CreatePixelShader failed: 0x%.8x', [HR]);
    Exit;
  end;
  FPixelShader := FDefaultPS;
  Result := True;
end;

procedure TD3D11ShaderRenderer.RecreateRenderTarget(W, H: Cardinal);
var
  BackBuf: ID3D11Texture2D;
begin
  if (FSwapChain = nil) or (FDevice = nil) then Exit;
  FRTV := nil;
  if Succeeded(FSwapChain.ResizeBuffers(0, Max(1, W), Max(1, H), DXGI_FORMAT_UNKNOWN, 0)) then
  begin
    if Succeeded(FSwapChain.GetBuffer(0, ID3D11Texture2D, BackBuf)) then
      FDevice.CreateRenderTargetView(BackBuf, nil, FRTV);
  end;
end;

function TD3D11ShaderRenderer.Initialize(AHwnd: HWND; AWidth, AHeight: Cardinal; out ErrorMsg: string): Boolean;
var
  SwapDesc: DXGI_SWAP_CHAIN_DESC;
  FeatLevel: D3D_FEATURE_LEVEL;
  HR: HRESULT;
  BackBuf: ID3D11Texture2D;
  SampDesc: D3D11_SAMPLER_DESC;
  CBDesc: D3D11_BUFFER_DESC;
begin
  Result := False;
  ErrorMsg := '';
  ReleaseDevice;

  FHwnd := AHwnd;
  FWidth := Max(64, AWidth);
  FHeight := Max(64, AHeight);

  ZeroMemory(@SwapDesc, SizeOf(SwapDesc));
  SwapDesc.BufferCount := 1;
  SwapDesc.BufferDesc.Width := FWidth;
  SwapDesc.BufferDesc.Height := FHeight;
  SwapDesc.BufferDesc.Format := DXGI_FORMAT_B8G8R8A8_UNORM;
  SwapDesc.BufferUsage := DXGI_USAGE_RENDER_TARGET_OUTPUT;
  SwapDesc.OutputWindow := AHwnd;
  SwapDesc.SampleDesc.Count := 1;
  SwapDesc.Windowed := True;
  SwapDesc.SwapEffect := DXGI_SWAP_EFFECT_DISCARD;

  HR := D3D11CreateDeviceAndSwapChain(nil, D3D_DRIVER_TYPE_HARDWARE, 0, 0, nil, 0,
    D3D11_SDK_VERSION, @SwapDesc, FSwapChain, FDevice, FeatLevel, FContext);
  if Failed(HR) then
    HR := D3D11CreateDeviceAndSwapChain(nil, D3D_DRIVER_TYPE_WARP, 0, 0, nil, 0,
      D3D11_SDK_VERSION, @SwapDesc, FSwapChain, FDevice, FeatLevel, FContext);
  if Failed(HR) then
  begin
    ErrorMsg := Format('D3D11CreateDeviceAndSwapChain failed: 0x%.8x', [HR]);
    Exit;
  end;

  if Failed(FSwapChain.GetBuffer(0, ID3D11Texture2D, BackBuf)) or
     Failed(FDevice.CreateRenderTargetView(BackBuf, nil, FRTV)) then
  begin
    ErrorMsg := 'Failed to create swap chain render target';
    ReleaseDevice;
    Exit;
  end;

  if not CompileBuiltinShaders(ErrorMsg) then
  begin
    ReleaseDevice;
    Exit;
  end;

  ZeroMemory(@SampDesc, SizeOf(SampDesc));
  SampDesc.Filter := D3D11_FILTER_MIN_MAG_MIP_LINEAR;
  SampDesc.AddressU := D3D11_TEXTURE_ADDRESS_CLAMP;
  SampDesc.AddressV := D3D11_TEXTURE_ADDRESS_CLAMP;
  SampDesc.AddressW := D3D11_TEXTURE_ADDRESS_CLAMP;
  FDevice.CreateSamplerState(SampDesc, FSampler);

  ZeroMemory(@CBDesc, SizeOf(CBDesc));
  CBDesc.ByteWidth := SizeOf(TShaderCBuffer);
  CBDesc.Usage := D3D11_USAGE_DYNAMIC;
  CBDesc.BindFlags := D3D11_BIND_CONSTANT_BUFFER;
  CBDesc.CPUAccessFlags := D3D11_CPU_ACCESS_WRITE;
  FDevice.CreateBuffer(CBDesc, nil, FCB);

  EnsureVideoTexture(FWidth, FHeight);
  FInitialized := True;
  Result := True;
end;

procedure TD3D11ShaderRenderer.EnsureVideoTexture(W, H: Cardinal);
var
  TexDesc: D3D11_TEXTURE2D_DESC;
begin
  if (FDevice = nil) or (W = 0) or (H = 0) then Exit;
  if (FVideoTex <> nil) and (FWidth = W) and (FHeight = H) then Exit;

  FWidth := W;
  FHeight := H;
  FVideoSRV := nil;
  FVideoTex := nil;

  ZeroMemory(@TexDesc, SizeOf(TexDesc));
  TexDesc.Width := W;
  TexDesc.Height := H;
  TexDesc.MipLevels := 1;
  TexDesc.ArraySize := 1;
  TexDesc.Format := DXGI_FORMAT_B8G8R8A8_UNORM;
  TexDesc.SampleDesc.Count := 1;
  TexDesc.Usage := D3D11_USAGE_DYNAMIC;
  TexDesc.BindFlags := D3D11_BIND_SHADER_RESOURCE;
  TexDesc.CPUAccessFlags := D3D11_CPU_ACCESS_WRITE;

  if Succeeded(FDevice.CreateTexture2D(TexDesc, nil, FVideoTex)) then
    FDevice.CreateShaderResourceView(FVideoTex, nil, FVideoSRV);
end;

procedure TD3D11ShaderRenderer.Resize(AWidth, AHeight: Cardinal);
begin
  if not FInitialized then Exit;
  FLock.Enter;
  try
    RecreateRenderTarget(AWidth, AHeight);
  finally
    FLock.Leave;
  end;
end;

function TD3D11ShaderRenderer.UploadLut3D(const ALut: TLut3DProfile; out ErrorMsg: string): Boolean;
var
  Desc: D3D11_TEXTURE3D_DESC;
  SubData: D3D11_SUBRESOURCE_DATA;
  HR: HRESULT;
begin
  Result := False;
  ErrorMsg := '';
  if not FInitialized or (FDevice = nil) then
  begin
    ErrorMsg := 'D3D11 device not initialized';
    Exit;
  end;
  if (ALut.Size < 2) or (Length(ALut.LatticeRGBA) < ALut.Size * ALut.Size * ALut.Size * 4) then
  begin
    ErrorMsg := 'Invalid 3D LUT lattice data';
    Exit;
  end;

  FLock.Enter;
  try
    FLutSRV := nil;
    FLutTex := nil;
    ZeroMemory(@Desc, SizeOf(Desc));
    Desc.Width := ALut.Size;
    Desc.Height := ALut.Size;
    Desc.Depth := ALut.Size;
    Desc.MipLevels := 1;
    Desc.Format := DXGI_FORMAT_R32G32B32A32_FLOAT;
    Desc.Usage := D3D11_USAGE_IMMUTABLE;
    Desc.BindFlags := D3D11_BIND_SHADER_RESOURCE;

    ZeroMemory(@SubData, SizeOf(SubData));
    SubData.pSysMem := @ALut.LatticeRGBA[0];
    SubData.SysMemPitch := ALut.Size * 16;
    SubData.SysMemSlicePitch := ALut.Size * ALut.Size * 16;

    HR := FDevice.CreateTexture3D(@Desc, @SubData, FLutTex);
    if Failed(HR) then
    begin
      ErrorMsg := Format('CreateTexture3D failed: 0x%.8x', [HR]);
      Exit;
    end;
    HR := FDevice.CreateShaderResourceView(FLutTex, nil, FLutSRV);
    if Failed(HR) then
    begin
      ErrorMsg := Format('CreateShaderResourceView(3D) failed: 0x%.8x', [HR]);
      Exit;
    end;
    FLutSize := ALut.Size;
    Include(FFlags, gsLut3D);
    Result := True;
  finally
    FLock.Leave;
  end;
end;

function TD3D11ShaderRenderer.LoadCustomHLSL(const AFilePath: string; out ErrorMsg: string): Boolean;
var
  RawText, Wrapped: string;
  Src: AnsiString;
  PSBlob, ErrBlob: ID3DBlob;
  NewPS: ID3D11PixelShader;
  HR: HRESULT;
begin
  Result := False;
  ErrorMsg := '';
  if not FInitialized or (FDevice = nil) then
  begin
    ErrorMsg := 'D3D11 device not initialized';
    Exit;
  end;
  if not TFile.Exists(AFilePath) then
  begin
    ErrorMsg := 'HLSL file not found';
    Exit;
  end;

  RawText := TFile.ReadAllText(AFilePath, TEncoding.UTF8);
  // Auto-adapt PotPlayer / MPC-HC PxShader (*.txt) ps_2_0 / ps_3_0 syntax to D3D11 ps_4_0
  if (Pos('tex2D', RawText) > 0) or (Pos(': COLOR', UpperCase(RawText)) > 0) then
  begin
    RawText := TRegEx.Replace(RawText, '^\s*sampler\s+s0\s*:\s*register\s*\(\s*s0\s*\)\s*;', '', [roIgnoreCase, roMultiLine]);
    RawText := TRegEx.Replace(RawText, '^\s*float4\s+p0\s*:\s*register\s*\(\s*c0\s*\)\s*;', '', [roIgnoreCase, roMultiLine]);
    RawText := TRegEx.Replace(RawText, '^\s*float4\s+p1\s*:\s*register\s*\(\s*c1\s*\)\s*;', '', [roIgnoreCase, roMultiLine]);
    RawText := TRegEx.Replace(RawText, '#define\s+one_over_width\s+\(p1\[0\]\)', '#define one_over_width (p0[2])', [roIgnoreCase]);
    RawText := TRegEx.Replace(RawText, '#define\s+one_over_height\s+\(p1\[1\]\)', '#define one_over_height (p0[3])', [roIgnoreCase]);
    Wrapped :=
      'Texture2D _PotTex : register(t0);' + #10 +
      'SamplerState _PotSamp : register(s0);' + #10 +
      'cbuffer _PotCB : register(b0) { float4 p0; float4 p1; };' + #10 +
      '#define tex2D(s, uv) _PotTex.Sample(_PotSamp, (uv))' + #10 +
      '#define COLOR SV_TARGET' + #10 +
      RawText;
    Src := AnsiString(Wrapped);
  end
  else
    Src := AnsiString(RawText);

  HR := D3DCompile(PAnsiChar(Src), Length(Src), PAnsiChar(AnsiString(AFilePath)), nil, nil,
    'PSMain', 'ps_4_0', 0, 0, PSBlob, ErrBlob);
  if Failed(HR) then
    HR := D3DCompile(PAnsiChar(Src), Length(Src), PAnsiChar(AnsiString(AFilePath)), nil, nil,
      'main', 'ps_4_0', 0, 0, PSBlob, ErrBlob);
  if Failed(HR) then
  begin
    if ErrBlob <> nil then ErrorMsg := string(PAnsiChar(ErrBlob.GetBufferPointer))
    else ErrorMsg := Format('HLSL compile failed: 0x%.8x', [HR]);
    Exit;
  end;

  HR := FDevice.CreatePixelShader(PSBlob.GetBufferPointer, PSBlob.GetBufferSize, nil, NewPS);
  if Failed(HR) then
  begin
    ErrorMsg := Format('CreatePixelShader failed: 0x%.8x', [HR]);
    Exit;
  end;

  FLock.Enter;
  try
    FPixelShader := NewPS;
  finally
    FLock.Leave;
  end;
  Result := True;
end;

procedure TD3D11ShaderRenderer.ResetCustomHLSL;
begin
  FLock.Enter;
  try
    FPixelShader := FDefaultPS;
  finally
    FLock.Leave;
  end;
end;

procedure TD3D11ShaderRenderer.RenderFrame(const Data: Pointer; Pitch, W, H: Cardinal);
var
  Mapped: D3D11_MAPPED_SUBRESOURCE;
  Row: Cardinal;
  SrcP, DstP: PByte;
  VP: D3D11_VIEWPORT;
  Params: ^TShaderCBuffer;
  FlagBits: Cardinal;
  RC: TRect;
begin
  if not FInitialized or (Data = nil) or (FVideoTex = nil) or (FRTV = nil) then Exit;

  if Succeeded(FContext.Map(FVideoTex, 0, D3D11_MAP_WRITE_DISCARD, 0, Mapped)) then
  begin
    try
      SrcP := PByte(Data);
      DstP := PByte(Mapped.pData);
      for Row := 0 to Min(H, FHeight) - 1 do
      begin
        Move(SrcP^, DstP^, Min(Pitch, Mapped.RowPitch));
        Inc(SrcP, Pitch);
        Inc(DstP, Mapped.RowPitch);
      end;
    finally
      FContext.Unmap(FVideoTex, 0);
    end;
  end;

  if Succeeded(FContext.Map(FCB, 0, D3D11_MAP_WRITE_DISCARD, 0, Mapped)) then
  begin
    try
      Params := Mapped.pData;
      Params^.TexSizeX := FWidth;
      Params^.TexSizeY := FHeight;
      Params^.InvTexX := 1.0 / Max(1, FWidth);
      Params^.InvTexY := 1.0 / Max(1, FHeight);
      FlagBits := 0;
      if gsAnime4K in FFlags then FlagBits := FlagBits or 1;
      if gsCAS in FFlags then FlagBits := FlagBits or 2;
      if gsDeband in FFlags then FlagBits := FlagBits or 4;
      if gsACES in FFlags then FlagBits := FlagBits or 8;
      if gsCRT in FFlags then FlagBits := FlagBits or 16;
      if gsLevels16_235 in FFlags then FlagBits := FlagBits or 32;
      if gsBT601to709 in FFlags then FlagBits := FlagBits or 64;
      Params^.Flags := FlagBits;
      if (gsLut3D in FFlags) and (FLutSRV <> nil) then Params^.LutEnabled := 1
      else Params^.LutEnabled := 0;
      Params^.LutSize := FLutSize;
      Params^.TimeSec := (GetTickCount64 - FStartTick) / 1000.0;
    finally
      FContext.Unmap(FCB, 0);
    end;
  end;

  GetClientRect(FHwnd, RC);
  ZeroMemory(@VP, SizeOf(VP));
  VP.Width := Max(1, RC.Width);
  VP.Height := Max(1, RC.Height);
  VP.MaxDepth := 1.0;

  FContext.OMSetRenderTargets(1, FRTV, nil);
  FContext.RSSetViewports(1, @VP);
  FContext.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
  FContext.VSSetShader(FVertexShader, nil, 0);
  FContext.PSSetShader(FPixelShader, nil, 0);
  FContext.PSSetConstantBuffers(0, 1, FCB);
  FContext.PSSetSamplers(0, 1, FSampler);
  FContext.PSSetShaderResources(0, 1, FVideoSRV);
  if FLutSRV <> nil then
    FContext.PSSetShaderResources(1, 1, FLutSRV);

  FContext.Draw(3, 0);
  FSwapChain.Present(0, 0);
end;

procedure TD3D11ShaderRenderer.AttachToPlayer(Player: Plibvlc_media_player_t);
begin
  if (Player = nil) then Exit;
  if Assigned(libvlc_video_set_format_callbacks) then
    libvlc_video_set_format_callbacks(Player, @VlcFormatCB, nil);
  if Assigned(libvlc_video_set_callbacks) then
    libvlc_video_set_callbacks(Player, @VlcLockCB, @VlcUnlockCB, @VlcDisplayCB, Self);
end;

end.
