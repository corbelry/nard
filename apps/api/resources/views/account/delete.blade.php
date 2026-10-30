<!DOCTYPE html>
<html lang="{{ $lang }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="noindex">
    <title>{{ __('deletion.title') }} · NardArena</title>
    {{-- Ceviz theme tokens from the nardarena-design skill (nard_colors.dart). --}}
    <style>
        :root {
            --bg: #2B1D14; --surface: #34251A; --text: #F3EBDD; --text-dim: rgba(243, 235, 221, .64);
            --line: rgba(201, 162, 74, .24); --accent: #C9A24A; --accent-hi: #E8C468;
            --primary-text: #231709; --danger-text: #E0566C;
        }
        * { box-sizing: border-box; }
        body { margin: 0; min-height: 100vh; background: var(--bg); color: var(--text);
            font: 15px/22px system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
            display: flex; justify-content: center; padding: 40px 16px; }
        main { width: 100%; max-width: 420px; }
        nav { display: flex; gap: 12px; justify-content: flex-end; margin-bottom: 32px; }
        nav a { color: var(--text-dim); text-decoration: none; font-size: 13px; text-transform: uppercase; }
        nav a[aria-current] { color: var(--accent-hi); }
        h1 { font-size: 26px; line-height: 32px; margin: 0 0 12px; }
        p { color: var(--text-dim); margin: 0 0 16px; }
        .card { background: var(--surface); border: 1px solid var(--line); border-radius: 16px; padding: 20px; margin-top: 24px; }
        label { display: block; font-size: 13px; margin-bottom: 8px; }
        input { width: 100%; padding: 12px 14px; border-radius: 12px; border: 1px solid var(--line);
            background: var(--bg); color: var(--text); font-size: 16px; }
        input:focus { outline: 2px solid var(--accent); outline-offset: 1px; }
        button { width: 100%; margin-top: 16px; padding: 14px; border: 0; border-radius: 12px; cursor: pointer;
            background: linear-gradient(#DCB862, #C29A43 55%, #A8822F); color: var(--primary-text);
            font-weight: 600; font-size: 15px; }
        .error { color: var(--danger-text); font-size: 13px; margin: 8px 0 0; }
        ul { color: var(--text-dim); padding-left: 20px; margin: 0 0 16px; }
    </style>
</head>
<body>
<main>
    <nav>
        @foreach ($langs as $l)
            <a href="/delete-account?lang={{ $l }}" @if ($l === $lang) aria-current="true" @endif>{{ $l }}</a>
        @endforeach
    </nav>

    <h1>{{ $step === 'done' ? __('deletion.done_title') : __('deletion.title') }}</h1>

    @if ($step === 'email')
        <p>{{ __('deletion.intro') }}</p>
        <ul>
            <li>{{ __('deletion.what_deleted') }}</li>
            <li>{{ __('deletion.grace', ['days' => config('nard.deletion_grace_days')]) }}</li>
            <li>{{ __('deletion.guests') }}</li>
        </ul>
        <form class="card" method="post" action="/delete-account/code">
            @csrf
            <input type="hidden" name="lang" value="{{ $lang }}">
            <label for="email">{{ __('deletion.email_label') }}</label>
            <input id="email" name="email" type="email" autocomplete="email" required value="{{ old('email') }}">
            @error('email') <p class="error">{{ __('deletion.email_invalid') }}</p> @enderror
            <button type="submit">{{ __('deletion.send_code') }}</button>
        </form>
    @elseif ($step === 'code')
        <p>{{ __('deletion.code_sent', ['email' => $email]) }}</p>
        <form class="card" method="post" action="/delete-account/confirm">
            @csrf
            <input type="hidden" name="lang" value="{{ $lang }}">
            <input type="hidden" name="email" value="{{ $email }}">
            <label for="code">{{ __('deletion.code_label') }}</label>
            <input id="code" name="code" inputmode="numeric" autocomplete="one-time-code" maxlength="6" required>
            @isset($error) <p class="error">{{ $error }}</p> @endisset
            <button type="submit">{{ __('deletion.confirm') }}</button>
        </form>
    @else
        <p>{{ __('deletion.done_body', ['date' => $deletesAt]) }}</p>
    @endif

    <p style="margin-top: 24px; font-size: 13px;">{{ __('deletion.support', ['email' => config('nard.support_email')]) }}</p>
</main>
</body>
</html>
