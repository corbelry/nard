<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Attachment;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;

/** 15.2: the player's data export, attached as a ZIP (QUESTIONS #17). */
class DataExportMail extends Mailable
{
    use Queueable;

    public function __construct(public string $zip) {}

    public function envelope(): Envelope
    {
        return new Envelope(subject: __('nard.export_subject'));
    }

    public function content(): Content
    {
        return new Content(text: 'mail.data-export');
    }

    /** @return list<Attachment> */
    public function attachments(): array
    {
        return [Attachment::fromData(fn () => $this->zip, 'nardarena-data.zip')->withMime('application/zip')];
    }
}
