<?php

use App\Models\StorePaymentMethod;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;

return new class extends Migration
{
    public function up(): void
    {
        $this->publishIcon('cash.png');
        $iconPath = $this->publishIcon('kuraimi.png');

        StorePaymentMethod::query()->updateOrCreate(
            ['slug' => 'kuraimi'],
            [
                'label' => 'حاسب كريمي',
                'hint' => 'حوّل إلى حساب بنك الكريمي ثم أكّد التحويل مع المتجر',
                'icon' => 'bi-bank',
                'icon_url' => $iconPath,
                'sort_order' => 10,
                'is_active' => true,
            ],
        );

        // حدّث أيقونة الدفع عند الاستلام الثابتة
        $cashIcon = $this->publishIcon('cash.png');
        StorePaymentMethod::query()
            ->where('slug', 'cash')
            ->update([
                'icon' => 'bi-cash-coin',
                'icon_url' => $cashIcon,
                'label' => 'الدفع عند الاستلام',
                'hint' => 'ادفع كاش لمندوب التوصيل عند استلام الطلب',
            ]);

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
            'kuraimi' => 10,
        ];
        foreach ($order as $slug => $sort) {
            StorePaymentMethod::query()->where('slug', $slug)->update(['sort_order' => $sort]);
        }
    }

    public function down(): void
    {
        StorePaymentMethod::query()->where('slug', 'kuraimi')->delete();
    }

    private function publishIcon(string $filename): ?string
    {
        $source = public_path('images/payments/'.$filename);
        if (! is_file($source)) {
            $source = storage_path('app/public/payments/'.$filename);
        }
        if (! is_file($source)) {
            return null;
        }

        Storage::disk('public')->makeDirectory('payments');
        $target = 'payments/'.$filename;
        File::copy($source, storage_path('app/public/'.$target));

        return $target;
    }
};
