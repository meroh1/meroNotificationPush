import { BadRequestException, Body, Controller, Post } from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiBody,
  ApiInternalServerErrorResponse,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { FcmService } from './fcm.service';
import { NotifyDto } from './dto/notify.dto';

@ApiTags('notify')
@Controller('notify')
export class FcmController {
  constructor(private readonly fcm: FcmService) {}

  @Post()
  @ApiOperation({ summary: 'Enviar notificación push', description: 'API para enviar notificaciones push vía FCM' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        title: { type: 'string', example: '¡Actualización disponible!' },
        body: { type: 'string', example: 'Versión 2.0 ya está en la tienda.' },
      },
      required: ['title', 'body'],
    },
  })
  @ApiResponse({ status: 200, description: 'éxito' })
  @ApiBadRequestResponse({ description: 'si title o body están vacíos' })
  @ApiInternalServerErrorResponse({ description: 'error interno (ej: FCM falló)' })
  async notify(@Body() dto: NotifyDto) {
    if (!dto.title?.trim() || !dto.body?.trim()) {
      throw new BadRequestException('title y body son obligatorios');
    }
    const result = await this.fcm.sendToTargets(dto.title.trim(), dto.body.trim());
    const failures = result.responses.filter(r => !r.success).length;
    return {
      successCount: result.successCount,
      failureCount: result.failureCount,
      failures,
    };
  }
}

