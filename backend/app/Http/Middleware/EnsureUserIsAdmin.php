<?php

namespace App\Http\Middleware;

use App\Models\User;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsAdmin
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (! $user instanceof User || ! $user->canAccessAdminPanel()) {
            abort(403, 'غير مصرح لك بالدخول إلى لوحة التحكم.');
        }

        $routeName = $request->route()?->getName();
        if (! $user->canAccessRoute($routeName)) {
            throw new HttpException(403, 'ليست لديك صلاحية للوصول إلى هذا القسم.');
        }

        return $next($request);
    }
}
