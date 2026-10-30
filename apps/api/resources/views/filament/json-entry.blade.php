{{-- Read-only pretty JSON (match games with seeds, flag details). --}}
<pre style="font-size: 12px; line-height: 1.4; max-height: 32rem; overflow: auto; white-space: pre-wrap; word-break: break-all;">{{ json_encode($getState(), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) }}</pre>
