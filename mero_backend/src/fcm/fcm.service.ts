import { Injectable, InternalServerErrorException, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { join } from 'path';

const TARGET_TOKENS: string[] = [
  // Reemplaza con tokens FCM reales para pruebas
  'c9_m4EPnSR-ENVT7QiZXVy:APA91bHOcH-3aoCsEVWQHJF1wbme6SoQlAAK3sU4waqF25u2KEzZCHSjxkDA8Tvn2m2i7QX-mAglBhTuZtTEhH4FsiJGeH_HF9VMPs6ACwCp0vTDyIKPZ7A',
  'cyxSQ9OmQS2rWMuLWCHTtP:APA91bG6u6WS7SV6BQRixLIdOaLUpkvUY72pfjTMv3eJKLwzhRV3POYBauTwRd8jEVH58a0DDGSCegRz1dIohjxztKIinLF0COa4yQyOTrB-fkt-xJatQ28',
  'cMGoA3WXTh2rS532B2fmzd:APA91bEvXh-QmShOqR7QaIBOp1MShVJOZZFyqiFZiua4ulfoYLNpbmXHEG50yxKlYscqvFbRfZcqUY-fXmdunOJpeuTlk88HQjEnnkxC4zTdrbJzmelaHGI'
];

@Injectable()
export class FcmService {
  private initialized = false;

  private ensureInitialized() {
    if (this.initialized) return;
    const serviceAccountPath = join(process.cwd(), 'src', 'config', 'serviceAccountKey.json');
    try {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccountPath),
      });
      this.initialized = true;
    } catch (err) {
      throw new InternalServerErrorException('No se pudo inicializar Firebase Admin. Verifica serviceAccountKey.json');
    }
  }

  async sendToTargets(title: string, body: string): Promise<admin.messaging.BatchResponse> {
    this.ensureInitialized();
    const messaging = admin.messaging();

    const message: admin.messaging.MessagingPayload = {
      notification: { title, body },
    } as any;

    // Usa sendEachForMulticast para ver éxito/falla por token
    const response = await messaging.sendEachForMulticast({
      tokens: TARGET_TOKENS,
      notification: { title, body },
      data: {},
    });

    return response;
  }
}

