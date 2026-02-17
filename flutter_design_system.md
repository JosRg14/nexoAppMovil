# NEXOAPP FLUTTER DESIGN SYSTEM

## 1. Configuración de Tema (ThemeData)
* **Colors:**
    * `scaffoldBackgroundColor`: `Color(0xFF1A1A1A)` (Gris Oscuro).
    * `primaryColor`: `Color(0xFF000000)` (Negro puro para botones/elementos).
    * `colorScheme.onSurface`: `Color(0xFFF3F4F6)` (Texto Blanco Hueso).
* **Typography:**
    * Usar paquete `google_fonts`. Fuente: 'Outfit' o 'Manrope'.
    * `headlineLarge`: FontWeight.bold, letterSpacing: 1.5 (Wide).

## 2. Componentes UI (Widgets)

### A. Inputs (TextField)
* No usar bordes rectangulares `OutlineInputBorder`.
* Usar **`UnderlineInputBorder`**:
    * `borderSide`: `BorderSide(color: Colors.grey[800])`.
    * `focusedBorder`: `BorderSide(color: Colors.white)`.
* `filled`: false (transparente).

### B. Botones (ElevatedButton)
* `style`: `ElevatedButton.styleFrom(...)`.
* `shape`: `RoundedRectangleBorder(borderRadius: BorderRadius.zero)` (Rectangulares, estilo brutalista).
* `backgroundColor`: `Colors.white` (o Negro invertido).
* **Interacción:** En móvil no existe "Hover", existe "Splash" o "Press". El botón debe cambiar de color al ser presionado.

## 3. Layout Móvil (Adaptación)
* **Adiós Split-Screen:** En un celular vertical NO PODEMOS dividir la pantalla izquierda/derecha.
* **Estrategia Visual:**
    * **Opción A (Fondo):** Imagen de barbería en blanco y negro ocupando toda la pantalla (`Stack` + `Positioned.fill`), con un `Container` encima con color negro y opacidad (0.8) para que el texto se lea.
    * **Opción B (Header):** Imagen visual en el tercio superior (30% altura) y formulario abajo (70% altura) con fondo sólido `#1a1a1a`.