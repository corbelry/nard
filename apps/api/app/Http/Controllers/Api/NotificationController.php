<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\Notifier;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

/** Inbox (16.2), settings (16.1) and push devices (docs/api/notifications.md). */
class NotificationController extends Controller
{
    private const TIME = 'regex:/^([01]\d|2[0-3]):[0-5]\d$/';

    public function __construct(private Notifier $notifier) {}

    public function index(Request $request): JsonResponse
    {
        $data = $request->validate([
            'after' => ['nullable', 'integer', 'min:0'],
            'limit' => ['nullable', 'integer', 'min:1', 'max:100'],
        ]);
        $user = $this->user($request);

        return response()->json([
            'notifications' => $this->notifier->inbox($user, isset($data['after']) ? (int) $data['after'] : null, (int) ($data['limit'] ?? 50)),
            'unread' => $this->notifier->unread($user),
        ]);
    }

    public function read(Request $request): JsonResponse
    {
        $data = $request->validate([
            'all' => ['required_without:ids', 'boolean'],
            'ids' => ['required_without:all', 'array', 'max:200'],
            'ids.*' => ['integer'],
        ]);
        $user = $this->user($request);
        $all = (bool) ($data['all'] ?? false);
        $this->notifier->markRead($user, $all ? null : array_map('intval', $data['ids'] ?? []));

        return response()->json(['unread' => $this->notifier->unread($user)]);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $user = $this->user($request);
        if (! $this->notifier->delete($user, $id)) {
            return response()->json(['code' => 'not_found'], 404);
        }

        return response()->json(['unread' => $this->notifier->unread($user)]);
    }

    public function settings(Request $request): JsonResponse
    {
        return response()->json(['settings' => $this->notifier->settings($this->user($request)->id)]);
    }

    public function updateSettings(Request $request): JsonResponse
    {
        /** @var list<string> $categories */
        $categories = config('push.categories');
        $data = $request->validate([
            'push' => ['sometimes', 'boolean'],
            'quietHours' => ['sometimes', 'array'],
            'quietHours.enabled' => ['sometimes', 'boolean'],
            'quietHours.start' => ['sometimes', 'string', self::TIME],
            'quietHours.end' => ['sometimes', 'string', self::TIME],
            'categories' => ['sometimes', 'array'],
            'categories.*' => ['boolean'],
            'utcOffset' => ['sometimes', 'integer', 'between:-720,840'],
        ]);
        $unknown = array_diff(array_keys($data['categories'] ?? []), $categories);
        if ($unknown !== []) {
            return response()->json(['code' => 'unknown_category', 'categories' => array_values($unknown)], 422);
        }
        /** @var array{push?: bool, quietHours?: array{enabled?: bool, start?: string, end?: string}, categories?: array<string, bool>, utcOffset?: int} $data */
        $settings = $this->notifier->updateSettings($this->user($request)->id, $data);

        return response()->json(['settings' => $settings]);
    }

    public function registerDevice(Request $request): JsonResponse
    {
        $data = $request->validate([
            'platform' => ['required', Rule::in(['android', 'ios'])],
            'token' => ['required', 'string', 'min:16', 'max:512'],
            'locale' => ['nullable', Rule::in(['az', 'en', 'ru', 'tr'])],
            'utcOffset' => ['nullable', 'integer', 'between:-720,840'],
        ]);
        $this->notifier->registerDevice(
            $this->user($request),
            $data['platform'],
            $data['token'],
            $data['locale'] ?? null,
            isset($data['utcOffset']) ? (int) $data['utcOffset'] : null,
        );

        return response()->json(['ok' => true], 201);
    }

    public function unregisterDevice(Request $request): JsonResponse
    {
        $data = $request->validate(['token' => ['required', 'string', 'max:512']]);
        $this->notifier->unregisterDevice($this->user($request), $data['token']);

        return response()->json(['ok' => true]);
    }

    private function user(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();

        return $user;
    }
}
