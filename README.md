# Módulo de Listagem e Reprodução de Vídeos

Este módulo fornece funcionalidades para listar e reproduzir vídeos, com suporte a múltiplos idiomas e integração com o Firebase.

## Instalação

1. Adicione as seguintes dependências ao seu `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.x.x
  cloud_firestore: ^4.x.x
  youtube_player_flutter: ^8.x.x
  connectivity_plus: ^4.x.x
  shared_preferences: ^2.x.x
```

2. Execute `flutter pub get` para instalar as dependências.

3. Copie os seguintes diretórios do nosso projeto para o seu:
   - `lib/screens`
   - `lib/models`
   - `lib/services`
   - `lib/i18n`

4. Certifique-se de que seu projeto está configurado para usar o Firebase. Se não estiver, siga as instruções oficiais do Firebase para configuração.

## Uso

Para integrar a tela de listagem de vídeos em sua aplicação:

1. Importe o arquivo da tela principal:

```dart
import 'path/to/video_list_screen.dart';
```

2. Adicione um botão ou item de menu que navegue para a `VideoListScreen`:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => VideoListScreen()),
);
```

## Estrutura do Firebase

O módulo utiliza o Cloud Firestore do Firebase com a seguinte estrutura:

```
videos (coleção)
  |
  ├── [document_id] (documento)
  │   ├── id: String
  │   ├── index: Number
  │   ├── isFavorite: Boolean
  │   │
  │   └── attributes (subcoleção)
  │       ├── category (documento)
  │       │   ├── pt: String
  │       │   ├── en: String
  │       │   └── es: String
  │       ├── session (documento)
  │       │   ├── pt: String
  │       │   ├── en: String
  │       │   └── es: String
  │       ├── title (documento)
  │       │   ├── pt: String
  │       │   ├── en: String
  │       │   └── es: String
  │       ├── description (documento)
  │       │   ├── pt: String
  │       │   ├── en: String
  │       │   └── es: String
  │       ├── youtubeUrl (documento)
  │       │   ├── pt: String
  │       │   ├── en: String
  │       │   └── es: String
  │       └── thumbnailUrl (documento)
  │           ├── pt: String
  │           ├── en: String
  │           └── es: String
```

### Explicação da estrutura:

1. `videos` é a coleção principal que contém todos os documentos de vídeo.

2. Cada documento de vídeo tem um ID único (`[document_id]`) e contém os seguintes campos:
   - `id`: String - Um identificador único para o vídeo (pode ser igual ao `document_id`).
   - `index`: Number - Um número para ordenação dos vídeos.
   - `isFavorite`: Boolean - Indica se o vídeo está marcado como favorito.

3. Cada documento de vídeo contém uma subcoleção chamada `attributes`.

4. A subcoleção `attributes` contém documentos para cada atributo multilíngue do vídeo:
   - `category`: Categoria do vídeo.
   - `session`: Sessão ou grupo ao qual o vídeo pertence.
   - `title`: Título do vídeo.
   - `description`: Descrição do vídeo.
   - `youtubeUrl`: URL do vídeo no YouTube.
   - `thumbnailUrl`: URL da imagem de miniatura do vídeo.

5. Cada documento na subcoleção `attributes` contém campos para cada idioma suportado:
   - `pt`: Texto em português.
   - `en`: Texto em inglês.
   - `es`: Texto em espanhol.

### Como adicionar um novo vídeo:

1. Crie um novo documento na coleção `videos` com um ID único.
2. Defina os campos `id`, `index`, e `isFavorite` no documento principal.
3. Crie uma subcoleção `attributes` dentro do documento do vídeo.
4. Para cada atributo (category, session, title, description, youtubeUrl, thumbnailUrl), crie um documento na subcoleção `attributes`.
5. Em cada documento de atributo, adicione campos para cada idioma suportado (pt, en, es).

Exemplo de como adicionar um vídeo usando o console do Firebase ou um script:

```javascript
// Adicionar documento principal
firebase.firestore().collection('videos').add({
  id: "video1",
  index: 1,
  isFavorite: false
}).then((docRef) => {
  // Adicionar subcoleção attributes
  const attributes = docRef.collection('attributes');
  
  // Adicionar documentos para cada atributo
  attributes.doc('category').set({
    pt: "Categoria 1",
    en: "Category 1",
    es: "Categoría 1"
  });
  
  attributes.doc('title').set({
    pt: "Título do Vídeo",
    en: "Video Title",
    es: "Título del Video"
  });
  
  // Repetir para session, description, youtubeUrl, thumbnailUrl
});
```

Certifique-se de que as regras de segurança do Firestore permitam a leitura desses dados pelo seu aplicativo.

## Personalização

- Para adicionar suporte a novos idiomas, atualize os arquivos em `lib/i18n/`.
- Para modificar o estilo dos itens da lista, edite `lib/screens/widgets/video_tile_widget.dart`.
- Para alterar o comportamento de reprodução do vídeo, modifique `lib/screens/video_player_screen.dart`.

## Observações

- Certifique-se de que as regras de segurança do Firebase permitam leitura dos dados de vídeo.
- O módulo usa o pacote `youtube_player_flutter` para reprodução de vídeos do YouTube. Certifique-se de que seu aplicativo tem as permissões necessárias para reprodução de vídeo e acesso à internet.

Você tem razão, e peço desculpas pela omissão. Vou adicionar essas informações importantes ao README.md. Aqui está a seção adicional que deve ser incluída:

## Configuração para iOS e Android

### iOS

1. Abra o arquivo `ios/Runner/Info.plist` e adicione as seguintes chaves:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
<key>io.flutter.embedded_views_preview</key>
<true/>
```

Isso permite que o app carregue conteúdo de vídeo da web e use views embarcadas para o player de vídeo.

2. Se você planeja usar recursos de rede em segundo plano, adicione:

```xml
<key>UIBackgroundModes</key>
<array>
   <string>fetch</string>
   <string>remote-notification</string>
</array>
```

### Android

1. Abra o arquivo `android/app/src/main/AndroidManifest.xml` e adicione as seguintes permissões dentro da tag `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

2. Para suportar tela cheia em dispositivos Android com notch, adicione o seguinte dentro da tag `<application>`:

```xml
<meta-data
    android:name="android.max_aspect"
    android:value="2.1" />
```

3. Se você estiver usando o Firebase, certifique-se de que o arquivo `google-services.json` esteja na pasta `android/app/`.

4. Para suportar picture-in-picture no Android, adicione:

```xml
<activity
    ...
    android:supportsPictureInPicture="true"
    android:configChanges="screenSize|smallestScreenSize|screenLayout|orientation"
    ...>
```

Lembre-se de ajustar as configurações de acordo com as necessidades específicas do seu aplicativo e as políticas da loja de aplicativos.
```

Esta seção fornece instruções importantes para configurar corretamente os ambientes iOS e Android, garantindo que o módulo de vídeo funcione adequadamente em ambas as plataformas. Adicione esta seção ao README.md, preferencialmente após a seção de instalação e antes da seção de uso.

```