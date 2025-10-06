import { Injectable, InternalServerErrorException, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { join } from 'path';

const TARGET_TOKENS: string[] = [
  // Reemplaza con tokens FCM reales para pruebas
  'c0Hwk2wMSYmxCHq-kylFb_:APA91bF0wD4S0-U6nSp5LfWi54G_OpJjFFf4F7SsCBmK_ptG7ldUCGV-DpTyWC1Erj-54Hzex0dLPo1dpPKsgEEMy4-PIl9n1veKaoobPzzZHy__1I1CqpE',
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

