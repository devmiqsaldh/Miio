# Miio - Diário Pessoal

Aplicativo de diário para iOS desenvolvido com SwiftUI usando arquitetura MVVM.

## Funcionalidades

- Criar e editar entradas do diário
- Adicionar fotos às entradas
- Registrar localização com GPS
- Organizar com tags
- Buscar entradas
- Compartilhar em redes sociais (LinkedIn, Instagram, WhatsApp, etc.)
- Criar entradas via Siri
- Resumo automático e geração de tags com IA

## Arquitetura

O projeto usa MVVM (Model-View-ViewModel):

```
Miio/
├── Models/          # Modelos de dados
├── ViewModels/     # Lógica de negócio
├── Views/          # Interface SwiftUI
├── Services/       # Serviços (IA, Compartilhamento)
├── AppIntents/     # Siri e Shortcuts
├── DesignSystem/   # Sistema de design
├── Extensions/     # Extensões Swift
├── Widgets/        # Widgets
└── Utilities/      # Utilitários
```

## Frameworks Utilizados

### Frameworks Apple

- SwiftUI - Interface do usuário
- Foundation - Tipos e coleções básicas
- Combine - Programação reativa
- CoreLocation - Localização GPS
- PhotosUI - Seleção de fotos
- App Intents - Integração com Siri e Shortcuts
- UIKit - Compartilhamento
- UniformTypeIdentifiers - Tipos de conteúdo
- NaturalLanguage - Análise de texto e entidades
- WidgetKit - Widgets para a tela inicial

### Funcionalidades Obrigatórias Implementadas

#### 1. Extensions e Design System

**Extensions criadas:**
- Animation+Extensions.swift - Animações personalizadas
- Date+Extensions.swift - Formatação de datas
- String+Extensions.swift - Utilitários de string
- ViewBuilder+Extensions.swift - Helpers para ViewBuilder

**Design System:**
- DesignSystem.swift - Cores, tipografia, espaçamentos e componentes reutilizáveis
- Modificadores como .cardStyle(), .primaryButtonStyle()

#### 2. ViewBuilder

Implementado em ViewBuilder+Extensions.swift:
- Helpers para views condicionais
- Construção declarativa de interfaces
- Uso de @ViewBuilder em todo o projeto

#### 3. App Intents

Framework App Intents implementado:
- CreateEntryIntent - Criar entradas via Siri
- SearchEntriesIntent - Buscar entradas
- GetLastEntryIntent - Obter última entrada
- Integração com Siri, Shortcuts e Spotlight

#### 4. Animações e SPM

**Animações:**
- Animações discretas, breves e sutis
- Feedback visual em interações
- Transições suaves entre telas
- Animações de lista escalonadas
- Implementado em Animation+Extensions.swift

**SPM (Swift Package Manager):**
- Projeto configurado para usar SPM quando necessário

#### 5. Foundation Models

Framework Foundation Models implementado:
- Resumir entradas - Gera resumos automáticos
- Extrair entidades - Identifica pessoas e lugares (usando NSLinguisticTagger)
- Gerar tags - Sugere tags automaticamente
- Classificar sentimento - Analisa tom do texto
- Refinar texto - Transforma texto conforme instruções
- Entender texto - Responde perguntas sobre o conteúdo
- Compor escrita criativa - Gera histórias
- Gerar diálogo - Cria diálogos com vozes específicas

Implementado em FoundationModelsService.swift usando NaturalLanguage.

## Requisitos

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Como Usar

1. Clone o repositório
2. Abra Miio.xcodeproj no Xcode
3. Configure permissões no Info.plist:
   - NSLocationWhenInUseUsageDescription
   - NSPhotoLibraryUsageDescription
4. Execute no simulador ou dispositivo

## Estrutura do Código

### Models
- Entry.swift - Modelo de entrada do diário
- EntryStore.swift - Gerenciador de persistência

### ViewModels
- EntryViewModel.swift - Lógica de negócio das entradas

### Views
- EntryListView.swift - Lista de entradas
- EntryDetailView.swift - Detalhes da entrada
- EntryEditView.swift - Criar/editar entrada

### Services
- FoundationModelsService.swift - Serviço de IA
- ShareService.swift - Compartilhamento

### App Intents
- CreateEntryIntent.swift - Intents do app
- MiioAppShortcuts.swift - Configuração de atalhos

### Design System
- DesignSystem.swift - Sistema de design unificado

### Extensions
- Animation+Extensions.swift - Animações
- Date+Extensions.swift - Datas
- String+Extensions.swift - Strings
- ViewBuilder+Extensions.swift - ViewBuilder

### Widgets
- MiioWidget.swift - Widget para tela inicial

## Persistência

- Entradas salvas em UserDefaults
- Fotos salvas em Documents/Photos
- Backup automático com iCloud

## Privacidade

Todos os dados são armazenados localmente. Nenhuma informação é enviada para servidores externos.

## Documentação

Todo o código está documentado com comentários seguindo as convenções do Swift.

## Licença

Ver arquivo LICENSE.
