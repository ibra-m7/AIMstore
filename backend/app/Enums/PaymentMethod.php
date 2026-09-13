<?php

namespace App\Enums;

enum PaymentMethod: string
{
    case Cash = 'cash';
    case CashWallet = 'cash_wallet';
    case Jeeb = 'jeeb';
    case Floosak = 'floosak';
    case OneCash = 'onecash';
    case Jawali = 'jawali';
    case Banky = 'banky';
    case Easy = 'easy';
    case MobileMoney = 'mobile_money';
    case Kuraimi = 'kuraimi';

    // قيم قديمة تُبقى للتوافق مع الطلبات السابقة فقط.
    case Mada = 'mada';
    case ApplePay = 'apple_pay';
    case StcPay = 'stc_pay';
    case BankTransfer = 'bank_transfer';
    case Card = 'card';
    case Wallet = 'wallet';

    public function label(): string
    {
        return match ($this) {
            self::Cash => 'الدفع عند الاستلام',
            self::CashWallet => 'محفظة كاش',
            self::Jeeb => 'محفظة جيب',
            self::Floosak => 'فلوسك',
            self::OneCash => 'ون كاش',
            self::Jawali => 'جوالي',
            self::Banky => 'بنكي (بنك اليمن والكويت)',
            self::Easy => 'محفظة إيزي',
            self::MobileMoney => 'موبايل موني',
            self::Kuraimi => 'حاسب كريمي',
            self::Mada => 'مدى',
            self::Card => 'فيزا / ماستركارد',
            self::ApplePay => 'Apple Pay',
            self::StcPay, self::Wallet => 'STC Pay',
            self::BankTransfer => 'تحويل بنكي',
        };
    }

    public function hint(): string
    {
        return match ($this) {
            self::Cash => 'ادفع كاش لمندوب التوصيل عند استلام الطلب',
            self::CashWallet => 'ادفع عبر محفظة كاش ثم أكّد التحويل مع المتجر',
            self::Jeeb => 'ادفع عبر محفظة جيب ثم أكّد التحويل مع المتجر',
            self::Floosak => 'ادفع عبر محفظة فلوسك ثم أكّد التحويل مع المتجر',
            self::OneCash => 'ادفع عبر محفظة ون كاش ثم أكّد التحويل مع المتجر',
            self::Jawali => 'ادفع عبر محفظة جوالي ثم أكّد التحويل مع المتجر',
            self::Banky => 'ادفع عبر تطبيق بنكي لبنك اليمن والكويت ثم أكّد التحويل',
            self::Easy => 'ادفع عبر محفظة إيزي ثم أكّد التحويل مع المتجر',
            self::MobileMoney => 'ادفع عبر موبايل موني ثم أكّد التحويل مع المتجر',
            self::Kuraimi => 'حوّل إلى حساب بنك الكريمي ثم أكّد التحويل مع المتجر',
            self::Mada => 'بطاقة مدى — يُؤكد المتجر العملية',
            self::Card => 'ادفع ببطاقة فيزا أو ماستركارد — يُؤكد المتجر العملية',
            self::ApplePay => 'ادفع عبر Apple Pay — يُؤكد المتجر العملية',
            self::StcPay, self::Wallet => 'محفظة STC Pay — يُؤكد المتجر العملية',
            self::BankTransfer => 'حوّل على حساب المتجر ثم انتظر تأكيد الإدارة',
        };
    }

    /**
     * @return list<self>
     */
    public static function checkoutOptions(): array
    {
        return [
            self::Cash,
            self::CashWallet,
            self::Jeeb,
            self::Floosak,
            self::OneCash,
            self::Jawali,
            self::Banky,
            self::Easy,
            self::MobileMoney,
            self::Kuraimi,
        ];
    }

    public function isDigitalWallet(): bool
    {
        return match ($this) {
            self::CashWallet,
            self::Jeeb,
            self::Floosak,
            self::OneCash,
            self::Jawali,
            self::Banky,
            self::Easy,
            self::MobileMoney,
            self::StcPay,
            self::Wallet => true,
            default => false,
        };
    }
}
