<?php

namespace App\Http\Controllers\Admin;

use App\Enums\PromoType;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\OfferRequest;
use App\Models\Product;
use App\Models\Setting;
use App\Services\Admin\OfferService;
use App\Support\AppStrings;
use App\Support\Constants;
use App\Support\StoreSettings;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class OfferController extends Controller
{
    public function __construct(private readonly OfferService $offers) {}

    public function index(Request $request): View
    {
        $type = PromoType::fromRequest($request->query('type'));
        $filters = $request->only(['q']);

        return view('admin.offers.index', [
            'title' => AppStrings::NAV_PRODUCT_DISCOUNTS,
            'type' => $type,
            'offers' => $this->offers->paginate($type, $filters),
            'counts' => $this->offers->counts(),
            'filters' => $filters,
            'showDiscountsAsBanner' => StoreSettings::showDiscountsAsBanner(),
            'showOffersAsBanner' => StoreSettings::showOffersAsBanner(),
        ]);
    }

    public function updateBannerVisibility(Request $request): RedirectResponse
    {
        $enabled = $request->boolean('enabled');
        $type = PromoType::fromRequest($request->input('type'));
        $isOffer = $type === PromoType::Offer;

        Setting::setValue(
            $isOffer
                ? Constants::SETTING_SHOW_OFFERS_AS_BANNER
                : Constants::SETTING_SHOW_DISCOUNTS_AS_BANNER,
            $enabled ? '1' : '0',
        );

        return redirect()
            ->route('admin.offers.index', ['type' => $type->value])
            ->with('success', $enabled
                ? ($isOffer
                    ? 'تم تفعيل ظهور العروض كبنر في الرئيسية.'
                    : 'تم تفعيل ظهور الخصومات كبنر في الرئيسية.')
                : ($isOffer
                    ? 'تم إخفاء العروض من بنر الرئيسية.'
                    : 'تم إخفاء الخصومات من بنر الرئيسية.'));
    }

    public function create(Request $request): View
    {
        $type = PromoType::fromRequest($request->query('type'));

        return view('admin.offers.create', [
            'title' => $type->addLabel(),
            'type' => $type,
            'products' => $this->offers->availablePayload(),
        ]);
    }

    public function available(Request $request): JsonResponse
    {
        $except = $request->integer('except') ?: null;

        return response()->json([
            'products' => $this->offers->availablePayload($request->query('q'), $except),
        ]);
    }

    public function store(OfferRequest $request): RedirectResponse
    {
        $data = $request->validated();
        $type = PromoType::fromRequest($data['promo_type']);
        $count = $this->offers->applyMany($type, $data['product_ids'], $data);

        return redirect()
            ->route('admin.offers.index', ['type' => $type->value])
            ->with('success', $type === PromoType::Offer
                ? "تم تطبيق العرض على {$count} منتج."
                : "تم تطبيق الخصم على {$count} منتج.");
    }

    public function edit(Product $product): View
    {
        $product->loadMissing('primaryImage');
        $type = $product->promo_type ?? PromoType::Discount;

        return view('admin.offers.edit', [
            'title' => $type === PromoType::Offer ? 'تعديل العرض' : AppStrings::EDIT_OFFER,
            'type' => $type,
            'product' => $product,
        ]);
    }

    public function update(OfferRequest $request, Product $product): RedirectResponse
    {
        $data = $request->validated();
        $type = PromoType::fromRequest($data['promo_type']);
        $this->offers->applyMany($type, [$product->id], $data);

        return redirect()
            ->route('admin.offers.index', ['type' => $type->value])
            ->with('success', $type === PromoType::Offer ? 'تم تحديث العرض.' : AppStrings::OFFER_UPDATED);
    }

    public function destroy(Product $product): RedirectResponse
    {
        $type = $product->promo_type ?? PromoType::Discount;
        $this->offers->clear($product);

        return redirect()
            ->route('admin.offers.index', ['type' => $type->value])
            ->with('success', $type === PromoType::Offer ? 'تم إلغاء العرض عن المنتج.' : AppStrings::OFFER_DELETED);
    }

    public function bulkClear(Request $request): RedirectResponse
    {
        $type = PromoType::fromRequest($request->input('type'));
        $scope = (string) $request->input('scope', 'selected');
        $isOffer = $type === PromoType::Offer;

        if ($scope === 'all') {
            $count = $this->offers->clearMany($type);
        } else {
            $ids = $request->input('product_ids', []);
            if (! is_array($ids)) {
                $ids = $ids ? [$ids] : [];
            }
            $count = $this->offers->clearMany($type, $ids);
        }

        if ($count === 0) {
            return redirect()
                ->route('admin.offers.index', ['type' => $type->value])
                ->with('success', $scope === 'all'
                    ? "لا توجد {$type->plural()} لإلغائها."
                    : 'اختر منتجاً واحداً على الأقل.');
        }

        return redirect()
            ->route('admin.offers.index', ['type' => $type->value])
            ->with('success', $isOffer
                ? "تم إلغاء العرض عن {$count} منتج."
                : "تم إلغاء الخصم عن {$count} منتج.");
    }
}
