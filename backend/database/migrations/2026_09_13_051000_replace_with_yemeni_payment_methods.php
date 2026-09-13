<?php

use App\Models\StorePaymentMethod;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;

return new class extends Migration
{
    public function up(): void
    {
        $now = now();
        $methods = [
            [
                'slug' => 'cash',
                'label' => 'الدفع عند الاستلام',
                'hint' => 'ادفع كاش لمندوب التوصيل عند استلام الطلب',
                'icon' => 'bi-cash-coin',
                'file' => 'cash.png',
                'sort_order' => 1,
            ],
            [
                'slug' => 'jeeb',
                'label' => 'محفظة جيب',
                'hint' => 'ادفع عبر محفظة جيب ثم أكّد التحويل مع المتجر',
                'icon' => 'bi-wallet2',
                'file' => 'jeeb.png',
                'sort_order' => 2,
            ],
            [
                'slug' => 'floosak',
                'label' => 'فلوسك',
                'hint' => 'ادفع عبر محفظة فلوسك ثم أكّد التحويل مع المتجر',
                'icon' => 'bi-wallet2',
                'file' => 'floosak.png',
                'sort_order' => 3,
            ],
            [
                'slug' => 'onecash',
                'label' => 'ون كاش',
                'hint' => 'ادفع عبر محفظة ون كاش ثم أكّد التحويل مع المتجر',
                'icon' => 'bi-wallet2',
                'file' => 'onecash.png',
                'sort_order' => 4,
            ],
            [
                'slug' => 'jawali',
                'label' => 'جوالي',
                'hint' => 'ادفع عبر محفظة جوالي ثم أكّد التحويل مع المتجر',
                'icon' => 'bi-wallet2',
                'file' => 'jawali.png',
                'sort_order' => 5,
            ],
            [
                'slug' => 'banky',
                'label' => 'بنكي (بنك اليمن والكويت)',
                'hint' => 'ادفع عبر تطبيق بنكي لبنك اليمن والكويت ثم أكّد التحويل',
                'icon' => 'bi-bank',
                'file' => 'banky.png',
                'sort_order' => 6,
            ],
            [
                'slug' => 'easy',
                'label' => 'محفظة إيزي',
                'hint' => 'ادفع عبر محفظة إيزي ثم أكّد التحويل مع المتجر',
                'icon' => 'bi-wallet2',
                'file' => 'easy.png',
                'sort_order' => 7,
            ],
            [
                'slug' => 'mobile_money',
                'label' => 'موبايل موني',
                'hint' => 'ادفع عبر موبايل موني (CAC) ثم أكّد التحويل مع المتجر',
                'icon' => 'bi-phone',
                'file' => 'mobile_money.png',
                'sort_order' => 8,
            ],
        ];

        $keep = [];
        foreach ($methods as $method) {
            $keep[] = $method['slug'];
            $iconPath = $this->publishIcon($method['file']);

            StorePaymentMethod::query()->updateOrCreate(
                ['slug' => $method['slug']],
                [
                    'label' => $method['label'],
                    'hint' => $method['hint'],
                    'icon' => $method['icon'],
                    'icon_url' => $iconPath,
                    'sort_order' => $method['sort_order'],
                    'is_active' => true,
                ],
            );
        }

        // أخفِ طرق الدفع القديمة (سعودية) بدل حذفها إن كانت مستخدمة في طلبات.
        StorePaymentMethod::query()
            ->whereNotIn('slug', $keep)
            ->update(['is_active' => false, 'updated_at' => $now]);
    }

    public function down(): void
    {
        // لا نعيد الطرق السعودية تلقائياً.
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
