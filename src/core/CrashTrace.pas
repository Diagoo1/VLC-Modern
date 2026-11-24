unit CrashTrace;
interface
function LatestCrashTrace:string;
implementation
uses Winapi.Windows, System.SysUtils;
type
  PTrace=^TTrace;
  TTrace=record Count:Word; Frames:array[0..95] of Pointer; end;
function QueryModule(Flags:Cardinal; Address:PWideChar; var Module:HMODULE):BOOL; stdcall; external 'kernel32.dll' name 'GetModuleHandleExW';
var LastTrace:TTrace; Handler:Pointer;
function AddHandler(First:Cardinal; Callback:Pointer):Pointer; stdcall; external 'kernel32.dll' name 'AddVectoredExceptionHandler';
function RemoveHandler(Value:Pointer):Cardinal; stdcall; external 'kernel32.dll' name 'RemoveVectoredExceptionHandler';
function CaptureBacktrace(Skip,Capture:Cardinal; Frames:Pointer; Hash:Pointer):Word; stdcall; external 'kernel32.dll' name 'RtlCaptureStackBackTrace';
function Capture(P:PExceptionRecord):Pointer;
var Trace:PTrace;
begin
  Trace:=HeapAlloc(GetProcessHeap,HEAP_ZERO_MEMORY,SizeOf(TTrace));
  if Trace=nil then Exit(nil);
  Trace.Count:=CaptureBacktrace(0,32,@Trace.Frames[0],nil);
  Result:=Trace;
end;
function Describe(Info:Pointer):string;
var Trace:PTrace; Module:HMODULE; Name:array[0..MAX_PATH] of Char;
begin
  Result:=''; if Info=nil then Exit; Trace:=PTrace(Info);
  for var I:=0 to Trace.Count-1 do
  begin
    Module:=0;
    if QueryModule(6,
      PChar(Trace.Frames[I]),Module) then
    begin
      GetModuleFileName(Module,Name,Length(Name));
      Result:=Result+ExtractFileName(Name)+'+$'+IntToHex(NativeUInt(Trace.Frames[I])-NativeUInt(Module),8)+sLineBreak;
    end;
  end;
end;
function TraceException(P:PExceptionPointers):LongInt; stdcall;
var Words:array[0..1023] of NativeUInt; Bytes:NativeUInt;
begin
  if (GetCurrentThreadId=MainThreadID) and
    ((P.ExceptionRecord.ExceptionCode=$0EEDFADE) or (P.ExceptionRecord.ExceptionCode=EXCEPTION_ACCESS_VIOLATION)) then
  begin
    LastTrace.Count:=CaptureBacktrace(0,32,@LastTrace.Frames[0],nil);
    if LastTrace.Count=0 then begin LastTrace.Count:=1; LastTrace.Frames[0]:=P.ExceptionRecord.ExceptionAddress; end;
    if ReadProcessMemory(GetCurrentProcess,Pointer(PContext(P.ContextRecord)^.Esp),@Words,SizeOf(Words),Bytes) then
      for var I:=0 to Integer(Bytes div SizeOf(NativeUInt))-1 do
        if (Words[I]>NativeUInt(HInstance)+$1000) and (Words[I]<NativeUInt(HInstance)+$456000) and (LastTrace.Count<96) then
        begin LastTrace.Frames[LastTrace.Count]:=Pointer(Words[I]); Inc(LastTrace.Count); end;
  end;
  Result:=0;
end;
function LatestCrashTrace:string;
begin Result:=Describe(@LastTrace); end;
procedure Clean(Info:Pointer);
begin if Info<>nil then HeapFree(GetProcessHeap,0,Info); end;
initialization
  Handler:=AddHandler(1,@TraceException);
  if not Assigned(Exception.GetExceptionStackInfoProc) then
  begin
    Exception.GetExceptionStackInfoProc:=Capture;
    Exception.GetStackInfoStringProc:=Describe;
    Exception.CleanUpStackInfoProc:=Clean;
  end;
finalization
  if Handler<>nil then RemoveHandler(Handler);
end.
