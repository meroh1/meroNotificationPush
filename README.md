# Push Notifications System

Sistema de notificaciones push para aplicaciones móviles Flutter utilizando Firebase Cloud Messaging (FCM v1 API).

## Stack

- **Backend**: NestJS + TypeScript + Firebase Admin SDK
- **Mobile**: Flutter + Firebase Messaging
- **Admin Panel**: Flutter Desktop (opcional)

## Estructura del Proyecto

```
notification/
├── mero_backend/          # API REST con NestJS
├── mero_notification/     # App móvil Flutter (Android)
└── mero_admin_panel/      # Panel admin (Windows/macOS/Linux)
```

### Backend

```bash
cd mero_backend
npm install
npm run start:dev
```
### Frontend - appMeroNotification

```bash
cd mero_notification
flutter build apk --release (para movil fisico)
flutter run (antes se debe abrir un emulador)
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Licencia

MIT

