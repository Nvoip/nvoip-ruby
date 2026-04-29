# nvoip-ruby

Cliente Ruby simples para a API v2 da Nvoip, com foco nos fluxos principais de autenticação, ligações, OTP e WhatsApp.

## Requisitos

- Ruby 3.0+

## Configuração

```bash
cp .env.example .env
```

Ou exporte:

```bash
export NVOIP_NUMBERSIP="seu_numbersip"
export NVOIP_USER_TOKEN="seu_user_token"
export NVOIP_OAUTH_CLIENT_ID="seu_client_id"
export NVOIP_OAUTH_CLIENT_SECRET="seu_client_secret"
export NVOIP_CALLER="1049"
export NVOIP_TARGET_NUMBER="11999999999"
```

## Fluxos cobertos

- gerar `access_token`
- renovar token
- consultar saldo
- enviar SMS
- realizar chamada
- enviar OTP
- validar OTP
- listar templates de WhatsApp
- enviar template de WhatsApp

## Exemplos

- `ruby examples/create_access_token.rb`
- `ruby examples/get_balance.rb`
- `ruby examples/send_sms.rb`
- `ruby examples/create_call.rb`
- `ruby examples/send_otp.rb`
- `ruby examples/check_otp.rb`
- `ruby examples/list_whatsapp_templates.rb`
- `ruby examples/send_whatsapp_template.rb`

## SDK web

Para o fluxo de popup com telefone e código, use em conjunto o repositório `nvoip-web-sdk`. Este repo cobre o consumo server-side da API.

## Documentação oficial

- https://nvoip.docs.apiary.io/
- https://www.nvoip.com.br/api
