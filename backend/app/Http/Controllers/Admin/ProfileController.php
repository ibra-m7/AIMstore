<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Support\AppStrings;
use App\Support\Media;
use App\Support\PasswordRules;
use App\Support\Phone;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

class ProfileController extends Controller
{
    public function edit(Request $request): View
    {
        $user = $request->user();

        return view('admin.profile.edit', [
            'title' => AppStrings::NAV_PROFILE,
            'user' => $user,
            'avatarUrl' => Media::url($user->avatar),
        ]);
    }

    public function verifyPassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'current_password' => ['required', 'string'],
        ]);

        $user = $request->user();
        $ok = Hash::check($data['current_password'], (string) $user->password);

        return response()->json([
            'ok' => $ok,
            'message' => $ok
                ? 'كلمة المرور الحالية صحيحة.'
                : 'كلمة المرور الحالية غير صحيحة.',
        ]);
    }

    public function evaluatePassword(Request $request): JsonResponse
    {
        $password = (string) $request->input('password', '');

        return response()->json(PasswordRules::evaluate($password));
    }

    public function update(Request $request): RedirectResponse
    {
        $user = $request->user();

        $request->merge([
            'password' => $request->filled('password') ? $request->input('password') : null,
            'current_password' => $request->filled('current_password') ? $request->input('current_password') : null,
        ]);

        try {
            $data = $request->validate([
                'name' => ['required', 'string', 'max:120'],
                'job_title' => ['nullable', 'string', 'max:120'],
                'bio' => ['nullable', 'string', 'max:500'],
                'email' => [
                    'required',
                    'email',
                    'max:255',
                    Rule::unique('users', 'email')->ignore($user->id),
                ],
                'phone_country' => ['nullable', 'string', Rule::in(Phone::catalogCountryCodes())],
                'phone' => ['nullable', 'string', 'max:16'],
                'locale' => ['nullable', 'string', Rule::in(['ar', 'en'])],
                'avatar' => ['nullable', 'file', 'mimes:jpg,jpeg,png,webp,gif', 'max:4096'],
                'remove_avatar' => ['nullable', 'boolean'],
                'current_password' => ['nullable', 'required_with:password', 'string'],
                'password' => ['nullable', 'confirmed', PasswordRules::admin()],
            ], array_merge(PasswordRules::messages(), [
                'current_password.required_with' => 'أدخل كلمة المرور الحالية لتغيير كلمة المرور.',
            ]));
        } catch (ValidationException $e) {
            throw $e->redirectTo(route('admin.profile.edit'));
        }

        $phone = $this->normalizePhone(
            (string) ($data['phone_country'] ?? Phone::countryCode()),
            (string) ($data['phone'] ?? ''),
        );

        if (($data['password'] ?? null) !== null && ($data['password'] ?? '') !== '') {
            if (! Hash::check((string) ($data['current_password'] ?? ''), (string) $user->password)) {
                throw ValidationException::withMessages([
                    'current_password' => 'كلمة المرور الحالية غير صحيحة.',
                ])->redirectTo(route('admin.profile.edit'));
            }
        }

        $avatarPath = $user->avatar;
        if ($request->boolean('remove_avatar')) {
            Media::delete($avatarPath);
            $avatarPath = null;
        } elseif ($request->hasFile('avatar')) {
            $avatarPath = Media::store($request->file('avatar'), 'avatars/admins', $avatarPath);
        }

        $payload = [
            'name' => trim((string) $data['name']),
            'job_title' => trim((string) ($data['job_title'] ?? '')) ?: null,
            'bio' => trim((string) ($data['bio'] ?? '')) ?: null,
            'email' => strtolower(trim((string) $data['email'])),
            'phone' => $phone !== '' ? $phone : null,
            'locale' => $data['locale'] ?? $user->locale ?? 'ar',
            'avatar' => $avatarPath,
        ];

        if (($data['password'] ?? null) !== null && ($data['password'] ?? '') !== '') {
            $payload['password'] = $data['password'];
        }

        $user->fill($payload);
        $user->save();

        return redirect()
            ->route('admin.profile.edit')
            ->with('success', AppStrings::PROFILE_UPDATED);
    }

    private function normalizePhone(string $country, string $national): string
    {
        $national = trim($national);
        if ($national === '') {
            return '';
        }

        $normalized = Phone::combineGcc($country, $national)
            ?? Phone::normalizeGcc($country.$national)
            ?? Phone::normalize($national);

        if ($normalized === null) {
            throw ValidationException::withMessages([
                'phone' => 'رقم الهاتف غير صالح.',
            ])->redirectTo(route('admin.profile.edit'));
        }

        return $normalized;
    }
}
