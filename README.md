# AIMstore

منصة متجر إلكتروني متعددة الأجزاء:

```
AIMstore/
├── backend/   # Laravel API + لوحة التحكم + صفحة التسويق
├── mobile/    # تطبيق العملاء (Flutter)
└── courier/   # تطبيق الموصلين (Flutter)
```

## التشغيل السريع

### الباك اند
```bash
cd backend
cp .env.example .env   # إن لزم
composer install
php artisan migrate
php artisan serve
```

أو عبر Laragon مع DocumentRoot على `backend/public`.

### تطبيق العملاء
```bash
cd mobile
flutter pub get
flutter run
```

### تطبيق الموصلين
```bash
cd courier
flutter pub get
flutter run
```

## ملاحظات
- اضبط `API_BASE_URL` في تطبيقات Flutter ليشير إلى سيرفر الباك اند.
- بعد النقل، رابط التخزين: من داخل `backend` نفّذ `php artisan storage:link`.
