<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Services\LoginCodes;
use Illuminate\Contracts\View\View;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\App;

/**
 * Web account deletion for Google Play (QUESTIONS #45): e-mail → code →
 * the same 30-day grace as in-app deletion. Never creates an account and
 * answers the same whether or not the address is known. Guests (no
 * e-mail) delete in the app.
 */
class AccountDeletionController extends Controller
{
    private const LOCALES = ['az', 'en', 'ru', 'tr'];

    public function show(Request $request): View
    {
        $this->useLocale($request);

        return $this->page('email');
    }

    public function sendCode(Request $request, LoginCodes $codes): View
    {
        $locale = $this->useLocale($request);
        $email = $this->email($request);
        $user = User::query()->firstWhere('email', $email);
        if ($user !== null && $user->deletion_requested_at === null) {
            $codes->issue($email, $locale, 'deletion');
        }

        return $this->page('code', ['email' => $email]);
    }

    public function confirm(Request $request, LoginCodes $codes): View
    {
        $locale = $this->useLocale($request);
        $email = $this->email($request);
        $data = $request->validate(['code' => ['required', 'string', 'size:6']]);
        $error = $codes->check($email, $data['code']);
        $user = User::query()->firstWhere('email', $email);
        if ($error !== null || $user === null) {
            return $this->page('code', [
                'email' => $email,
                'error' => __('deletion.'.($error ?? 'code_expired')),
            ]);
        }

        $deletesAt = $user->requestDeletion();
        $deletesAt->locale($locale);

        return $this->page('done', ['deletesAt' => $deletesAt->isoFormat('LL')]);
    }

    private function email(Request $request): string
    {
        $data = $request->validate(['email' => ['required', 'email:rfc', 'max:255']]);

        return mb_strtolower($data['email']);
    }

    /** `?lang=`, else the browser language, else Azerbaijani. */
    private function useLocale(Request $request): string
    {
        $lang = $request->input('lang', $request->getPreferredLanguage(self::LOCALES));
        $lang = in_array($lang, self::LOCALES, true) ? $lang : 'az';
        App::setLocale($lang);

        return $lang;
    }

    /** @param array<string, string> $data */
    private function page(string $step, array $data = []): View
    {
        return view('account.delete', ['step' => $step, 'lang' => App::getLocale(), 'langs' => self::LOCALES, ...$data]);
    }
}
