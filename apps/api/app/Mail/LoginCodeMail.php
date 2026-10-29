<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;

/** One-time sign-in code (17.2 / 17.3), sent in the player's language. */
class LoginCodeMail extends Mailable
{
    use Queueable;

    public function __construct(public string $code, public int $minutes) {}

    public function envelope(): Envelope
    {
        return new Envelope(subject: __('nard.code_subject', ['code' => $this->code]));
    }

    public function content(): Content
    {
        return new Content(text: 'mail.login-code');
    }
}
