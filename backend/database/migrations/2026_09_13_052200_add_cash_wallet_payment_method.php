<?php

use App\Models\StorePaymentMethod;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;

return new class extends Migration
{
    public function up(): void
    {
        $source = public_path('images/payments/cash_wallet.png');
        if (! is_file($source)) {
            $source = storage_path('app/public/payments/cash_wallet.png');
        }

        $iconPath = null;
        if (is_file($source)) {
            Storage::disk('public')->makeDirectory('payments');
            $iconPath = 'payments/cash_wallet.png';
            File::copy($source, storage_path('app/public/'.$iconPath));
        }

        StorePaymentMethod::query()->updateOrCreate(
            ['slug' => 'cash_wallet'],
            [
                'label' => 'محفظة كاش',
                'hint' => 'ادفع عبر محفظة كاش ثم أكّد التحويل مع المتجر',
                'icon' => 'bi-wallet2',
                'icon_url' => $iconPath,
                'sort_order' => 2,
                'is_active' => true,
            ],
        );

        // أعد ترتيب المحافظ بعد الدفع عند الاستلام
        $order = [
            'cash' => 1,
            'cash_wallet' => 2,
            'jeeb' => 3,
            'floosak' => 4,
            'onecash' => 5,
            'jawali' => 6,
            'banky' => 7,
            'easy' => 8,
            'mobile_money' => 9,
        ];
        foreach ($order as $slug => $sort) {
            StorePaymentMethod::query()->where('slug', $slug)->update(['sort_order' => $sort]);
        }
    }

    public function down(): void
    {
        StorePaymentMethod::query()->where('slug', 'cash_wallet')->delete();
    }
};
