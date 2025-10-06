import { IsNotEmpty, IsString } from 'class-validator';

export class NotifyDto {
  @IsString()
  @IsNotEmpty()
  title!: string;

  @IsString()
  @IsNotEmpty()
  body!: string;
}

