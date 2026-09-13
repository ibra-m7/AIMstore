<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\User;
use App\Support\AdminPermissions;
use App\Support\AppStrings;
use App\Support\PasswordRules;
use App\Support\Phone;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

class StaffController extends Controller
{
    public function index(Request $request): View
    {
        $this->ensureCanManageTeam($request);

        $q = trim((string) $request->query('q', ''));

        $staff = User::query()
            ->whereIn('role', [UserRole::Admin, UserRole::Staff])
            ->when($q !== '', function ($query) use ($q) {
                $query->where(function ($inner) use ($q) {
                    $inner->where('name', 'like', "%{$q}%")
                        ->orWhere('email', 'like', "%{$q}%")
                        ->orWhere('phone', 'like', "%{$q}%")
                        ->orWhere('job_title', 'like', "%{$q}%");
                });
            })
            ->orderByRaw("CASE WHEN role = 'admin' THEN 0 ELSE 1 END")
            ->orderBy('name')
            ->paginate(20)
            ->withQueryString();

        return view('admin.staff.index', [
            'title' => AppStrings::NAV_TEAM,
            'staff' => $staff,
            'filters' => ['q' => $q],
            'permissionCatalog' => AdminPermissions::catalog(),
        ]);
    }

    public function create(Request $request): View
    {
        $this->ensureCanManageTeam($request);

        return view('admin.staff.create', [
            'title' => AppStrings::ADD_STAFF,
            'permissionCatalog' => AdminPermissions::catalog(),
            'assignableKeys' => AdminPermissions::assignableKeys(),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $this->ensureCanManageTeam($request);

        $data = $this->validated($request);

        User::query()->create([
            'name' => trim((string) $data['name']),
            'job_title' => trim((string) ($data['job_title'] ?? '')) ?: null,
            'email' => strtolower(trim((string) $data['email'])),
            'phone' => $this->normalizePhone(
                (string) ($data['phone_country'] ?? Phone::countryCode()),
                (string) ($data['phone'] ?? ''),
            ) ?: null,
            'password' => $data['password'],
            'role' => UserRole::Staff,
            'permissions' => $this->normalizedPermissions($data['permissions'] ?? []),
            'locale' => 'ar',
        ]);

        return redirect()
            ->route('admin.staff.index')
            ->with('success', AppStrings::STAFF_CREATED);
    }

    public function edit(Request $request, User $staff): View
    {
        $this->ensureCanManageTeam($request);
        $this->ensureEditableStaff($request, $staff);

        return view('admin.staff.edit', [
            'title' => AppStrings::EDIT_STAFF,
            'member' => $staff,
            'permissionCatalog' => AdminPermissions::catalog(),
            'assignableKeys' => AdminPermissions::assignableKeys(),
        ]);
    }

    public function update(Request $request, User $staff): RedirectResponse
    {
        $this->ensureCanManageTeam($request);
        $this->ensureEditableStaff($request, $staff);

        $data = $this->validated($request, $staff);

        $payload = [
            'name' => trim((string) $data['name']),
            'job_title' => trim((string) ($data['job_title'] ?? '')) ?: null,
            'email' => strtolower(trim((string) $data['email'])),
            'phone' => $this->normalizePhone(
                (string) ($data['phone_country'] ?? Phone::countryCode()),
                (string) ($data['phone'] ?? ''),
            ) ?: null,
            'permissions' => $this->normalizedPermissions($data['permissions'] ?? []),
        ];

        if (($data['password'] ?? null) !== null && $data['password'] !== '') {
            $payload['password'] = $data['password'];
        }

        $staff->fill($payload);
        $staff->save();

        return redirect()
            ->route('admin.staff.index')
            ->with('success', AppStrings::STAFF_UPDATED);
    }

    public function destroy(Request $request, User $staff): RedirectResponse
    {
        $this->ensureCanManageTeam($request);
        $this->ensureEditableStaff($request, $staff);

        if ((int) $staff->id === (int) $request->user()?->id) {
            throw ValidationException::withMessages([
                'staff' => 'لا يمكنك حذف حسابك الحالي.',
            ])->redirectTo(route('admin.staff.index'));
        }

        $staff->delete();

        return redirect()
            ->route('admin.staff.index')
            ->with('success', AppStrings::STAFF_DELETED);
    }

    /**
     * @return array<string, mixed>
     */
    private function validated(Request $request, ?User $staff = null): array
    {
        $request->merge([
            'password' => $request->filled('password') ? $request->input('password') : null,
        ]);

        $passwordRules = $staff === null
            ? ['required', 'confirmed', PasswordRules::admin()]
            : ['nullable', 'confirmed', PasswordRules::admin()];

        try {
            return $request->validate([
                'name' => ['required', 'string', 'max:120'],
                'job_title' => ['nullable', 'string', 'max:120'],
                'email' => [
                    'required',
                    'email',
                    'max:255',
                    Rule::unique('users', 'email')->ignore($staff?->id),
                ],
                'phone_country' => ['nullable', 'string', Rule::in(Phone::catalogCountryCodes())],
                'phone' => ['nullable', 'string', 'max:16'],
                'password' => $passwordRules,
                'permissions' => ['required', 'array', 'min:1'],
                'permissions.*' => ['string', Rule::in(AdminPermissions::assignableKeys())],
            ], array_merge(PasswordRules::messages(), [
                'permissions.required' => 'اختر صلاحية واحدة على الأقل.',
                'permissions.min' => 'اختر صلاحية واحدة على الأقل.',
            ]));
        } catch (ValidationException $e) {
            throw $e->redirectTo(
                $staff ? route('admin.staff.edit', $staff) : route('admin.staff.create')
            );
        }
    }

    /**
     * @param  list<mixed>  $permissions
     * @return list<string>
     */
    private function normalizedPermissions(array $permissions): array
    {
        $allowed = [];
        foreach ($permissions as $key) {
            $key = (string) $key;
            if (in_array($key, AdminPermissions::assignableKeys(), true) && ! in_array($key, $allowed, true)) {
                $allowed[] = $key;
            }
        }

        return $allowed;
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
            ]);
        }

        return $normalized;
    }

    private function ensureCanManageTeam(Request $request): void
    {
        if (! $request->user()?->hasPermission(AdminPermissions::TEAM)) {
            abort(403, 'إدارة الفريق متاحة لمدير النظام فقط.');
        }
    }

    private function ensureEditableStaff(Request $request, User $staff): void
    {
        if ($staff->isAdmin()) {
            abort(403, 'لا يمكن تعديل حساب المدير الرئيسي من هنا.');
        }

        if (! $staff->isStaff()) {
            abort(404);
        }
    }
}
