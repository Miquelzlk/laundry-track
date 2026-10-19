<?php

namespace App\Http\Middleware;

use App\Models\ApiToken as ApiTokenModel;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ApiToken
{
    public function handle(Request $request, Closure $next): Response
    {
        $plain = $request->bearerToken();
        $token = $plain
            ? ApiTokenModel::with('user')->where('token', hash('sha256', $plain))->first()
            : null;

        if (! $token || ! $token->user) {
            return response()->json(['message' => 'Sesi tidak valid. Silakan masuk kembali.'], 401);
        }

        $request->setUserResolver(fn () => $token->user);
        $request->attributes->set('api_token', $token);

        return $next($request);
    }
}