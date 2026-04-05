# Curriculo Lab

Plataforma em Flutter Web para:

- ler curriculos enviados pelo usuario
- comparar o perfil com uma vaga especifica
- gerar diagnostico de compatibilidade com a vaga
- apontar problemas de leitura para ATS
- recriar o curriculo com foco em melhores praticas para sistemas ATS

## Stack

- Flutter Web
- Riverpod para estado e injecao simples
- arquitetura em camadas com separacao entre presentation, domain e data
- Gemini via Google AI Studio API key, usando free-tier

## Arquitetura

Estrutura principal em [lib](lib):

- [lib/app](lib/app): bootstrap do app e tema global
- [lib/core](lib/core): constantes, erros e servicos compartilhados
- [lib/features/resume_optimizer/domain](lib/features/resume_optimizer/domain): entidades, contratos e caso de uso
- [lib/features/resume_optimizer/data](lib/features/resume_optimizer/data): datasource Gemini e repositorio
- [lib/features/resume_optimizer/presentation](lib/features/resume_optimizer/presentation): controller, providers, pagina e widgets

Essa divisao mantem o fluxo simples e coerente com SOLID:

- responsabilidade unica para cada camada
- dependencia da domain para contratos, nao para implementacoes concretas
- infraestrutura isolada na camada data
- UI consumindo apenas controller e estado

## Como rodar

1. Garanta que o Flutter esteja no PATH.
2. Rode `flutter pub get`.
3. Rode `flutter run -d chrome`.

Para build web:

1. Rode `flutter build web`.

## Como usar

1. Gere uma API key gratuita no Google AI Studio.
2. Cole a chave no campo inicial.
3. Informe a descricao da vaga.
4. Envie um curriculo em PDF, TXT ou MD, ou cole o texto manualmente.
5. Gere a analise.

## Observacoes importantes

- Este MVP chama o Gemini diretamente do navegador.
- A chave fica salva localmente no navegador via SharedPreferences.
- Para producao, o correto e mover a chamada para backend, edge function ou proxy seguro.
- O fluxo de upload prioriza PDF, TXT e MD para manter a leitura previsivel em Flutter Web.

## Validacao executada

- `flutter analyze`
- `flutter test`
- `flutter build web`
