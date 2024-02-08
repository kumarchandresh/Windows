# https://stackoverflow.com/a/49481797
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$OutputEncoding = [Console]::OutputEncoding = [Console]::InputEncoding = [Text.UTF8Encoding]::new()

function which() {
  (Get-Command $args -CommandType Application, ExternalScript -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source) -replace [Regex]::Escape($env:USERPROFILE), '~'
}
