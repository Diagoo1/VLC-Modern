param(
    [Parameter(Mandatory)][string]$FullPlugins,
    [Parameter(Mandatory)][string]$LitePackage
)
$ErrorActionPreference='Stop'
$source=(Resolve-Path -LiteralPath $FullPlugins).Path
$target=Join-Path (Resolve-Path -LiteralPath $LitePackage).Path 'plugins'
$modules=@{
    access=@('libfilesystem_plugin.dll','libhttp_plugin.dll','libhttps_plugin.dll','libtcp_plugin.dll')
    misc=@('libgnutls_plugin.dll')
    codec=@('libavcodec_plugin.dll','libdxva2_plugin.dll','libd3d11va_plugin.dll','libflac_plugin.dll','libmpg123_plugin.dll','libopus_plugin.dll','libvorbis_plugin.dll','liblibass_plugin.dll','libsubsdec_plugin.dll','libspdif_plugin.dll')
    demux=@('libmp4_plugin.dll','libmkv_plugin.dll','libavi_plugin.dll','libogg_plugin.dll','libflacsys_plugin.dll','libwav_plugin.dll','libes_plugin.dll','libasf_plugin.dll','libts_plugin.dll','libsubtitle_plugin.dll')
    audio_output=@('libmmdevice_plugin.dll','libwasapi_plugin.dll','libdirectsound_plugin.dll','libwaveout_plugin.dll','libadummy_plugin.dll')
    video_output=@('libdirect3d11_plugin.dll','libdirect3d9_plugin.dll','libdrawable_plugin.dll','libwingdi_plugin.dll','libvmem_plugin.dll','libvdummy_plugin.dll','libwinhibit_plugin.dll')
    stream_filter=@('libcache_block_plugin.dll','libcache_read_plugin.dll','libprefetch_plugin.dll','libskiptags_plugin.dll')
}
foreach($category in 'audio_filter','audio_mixer','video_filter','video_chroma','text_renderer','packetizer','d3d11','d3d9','logger','spu'){
    $modules[$category]=@(Get-ChildItem -LiteralPath (Join-Path $source $category) -Filter '*.dll' -Name)
}
foreach($category in $modules.Keys){
    $directory=New-Item -ItemType Directory -Path (Join-Path $target $category) -Force
    foreach($file in $modules[$category]){
        Copy-Item -LiteralPath (Join-Path $source "$category/$file") -Destination $directory.FullName -Force
    }
}

Set-Content -LiteralPath (Join-Path $target '.lite-baseline') -Value 'Lite starter pack' -Encoding ascii
