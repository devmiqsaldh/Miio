# 📔 Miio - Diário Pessoal

Aplicativo de diário completo para iOS desenvolvido com SwiftUI seguindo arquitetura MVVM.

## ✨ Funcionalidades

- **Criar e Editar Entradas**: Anote pensamentos, experiências e memórias
- **Fotos**: Adicione múltiplas fotos às entradas
- **Localização**: Registre lugares visitados com GPS
- **Tags**: Organize entradas com tags personalizadas
- **Busca**: Encontre entradas por título, conteúdo ou tags
- **Compartilhamento**: Compartilhe em redes sociais (LinkedIn, Instagram, WhatsApp, etc.)
- **Siri & Shortcuts**: Crie entradas via comandos de voz
- **Foundation Models**: Resumo automático, extração de entidades e geração de tags

## 🏗️ Arquitetura

**MVVM** (Model-View-ViewModel) com separação clara de responsabilidades:

```
Miio/                    # Raiz do projeto
├── Miio.xcodeproj/      # Projeto Xcode
├── Miio/                # Código fonte
│   ├── Models/          # Modelos de dados
│   ├── ViewModels/      # Lógica de negócio
│   ├── Views/           # Interface SwiftUI
│   ├── Services/        # Serviços (Foundation Models, Compartilhamento)
│   ├── AppIntents/      # Integração Siri/Shortcuts
│   ├── DesignSystem/    # Sistema de design
│   ├── Extensions/      # Extensões Swift
│   └── Utilities/       # Utilitários
├── README.md
└── LICENSE
```

## 🔧 Frameworks e Tecnologias

### Frameworks Apple

- **SwiftUI**: Interface do usuário declarativa
- **Foundation**: Framework base (tipos, coleções, formatação)
- **Combine**: Programação reativa e observação de dados
- **CoreLocation**: Localização GPS e geocodificação
- **PhotosUI**: Seleção e gerenciamento de fotos
- **App Intents**: Integração com Siri, Shortcuts e Spotlight
- **UIKit**: Compartilhamento e componentes do sistema
- **UniformTypeIdentifiers**: Identificação de tipos de conteúdo

### Padrões e Conceitos

- **MVVM**: Arquitetura Model-View-ViewModel
- **ViewBuilder**: Construção declarativa de interfaces
- **Extensions**: Extensões para tipos nativos (Date, String, View, Animation)
- **Design System**: Sistema de design unificado (cores, tipografia, espaçamentos)
- **Animações**: Animações discretas e sutis para feedback visual
- **Foundation Models**: Análise de texto e geração de conteúdo inteligente

## 📋 Requisitos

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 🚀 Instalação

1. Clone o repositório:
```bash
git clone [url-do-repositorio]
cd Miio
```

2. Abra o projeto no Xcode:
```bash
open Miio.xcodeproj
```

3. Configure permissões no `Info.plist`:
   - `NSLocationWhenInUseUsageDescription`: "Miio precisa da sua localização para adicionar lugares às suas entradas"
   - `NSPhotoLibraryUsageDescription`: "Miio precisa acessar suas fotos para adicionar imagens às suas entradas"

4. Compile e execute no simulador ou dispositivo

## 🎯 Uso

### Criar Entrada
Toque no botão **+** → Preencha título e conteúdo → (Opcional) Adicione fotos, localização ou tags → **Salvar**

### Buscar
Use a barra de busca na parte superior e digite palavras-chave

### Filtrar por Tags
Toque no ícone de tag no canto superior esquerdo e selecione uma tag

### Compartilhar
Abra uma entrada → Menu (três pontos) → **Compartilhar** → Escolha o destino

### Siri
- "Criar entrada no Miio: [conteúdo]"
- "Buscar no Miio: [termo]"
- "Última entrada no Miio"

## 🎨 Design System

Sistema de design unificado com:

- **Cores**: Paleta consistente (`DesignSystem.Colors`)
- **Tipografia**: Fontes padronizadas (`DesignSystem.Typography`)
- **Espaçamentos**: Valores consistentes (`DesignSystem.Spacing`)
- **Componentes**: Modificadores reutilizáveis (`.cardStyle()`, `.primaryButtonStyle()`)

## 📱 Funcionalidades Avançadas

### Foundation Models

Serviço `FoundationModelsService` com:

- **Resumir**: Gera resumos automáticos de entradas longas
- **Extrair Entidades**: Identifica pessoas e lugares mencionados
- **Gerar Tags**: Sugere tags baseadas no conteúdo
- **Classificar Sentimento**: Analisa tom (positivo, neutro, negativo)
- **Refinar Texto**: Transforma texto conforme instruções

### App Intents

Integração com sistema iOS:

- **CreateEntryIntent**: Criar entradas via Siri
- **SearchEntriesIntent**: Buscar entradas
- **GetLastEntryIntent**: Obter última entrada criada

### Animações

Animações discretas, breves e sutis:

- Transições suaves entre telas
- Feedback visual em interações
- Animações de lista escalonadas
- Efeitos de aparecimento/desaparecimento

## 💾 Persistência

- **Entradas**: `UserDefaults` (JSON codificado)
- **Fotos**: Diretório `Documents/Photos`
- **Backup**: Sincronização com iCloud (se habilitado)

## 🔒 Privacidade

- Dados armazenados localmente no dispositivo
- Nenhuma informação enviada para servidores externos
- Permissões solicitadas apenas quando necessário

## 📄 Licença

Ver arquivo `LICENSE`.

## 👨‍💻 Desenvolvimento

### Commits

Seguindo [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body opcional>

BREAKING CHANGE: <descrição opcional>

Refs: <JIRA|Issue-IDs>
```

### Documentação

Código documentado com `///` seguindo convenções Swift:

```swift
/// Descrição da função
/// - Parameter name: Descrição do parâmetro
/// - Returns: Descrição do retorno
func example(name: String) -> String
```

---

Desenvolvido com SwiftUI
