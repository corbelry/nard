<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;

/**
 * One-time code (17.2 / 17.3), sent in the player's language. `deletion`
 * codes confirm the web account-deletion page (QUESTIONS #45).
 */
class LoginCodeMail extends Mailable
{
    use Queueable;

    public function __construct(public string $code, public int $minutes, public string $purpose = 'sign_in') {}

    public function envelope(): Envelope
    {
        $key = $this->purpose === 'deletion' ? 'deletion.code_subject' : 'nard.code_subject';

        return new Envelope(subject: __($key, ['code' => $this->code]));
    }

    public function content(): Content
    {
        return new Content(text: 'mail.login-code');
    }
}
