# UpSessions Landing Page

Landing page moderna y atractiva para la plataforma UpSessions, construida con Astro.

## 🎯 Características

- **Diseño moderno**: Gradientes vibrantes, glassmorphism, y animaciones suaves
- **Totalmente responsive**: Optimizada para móvil, tablet y desktop
- **Performance**: Astro genera sitios ultra-rápidos con mínimo JavaScript
- **SEO optimizado**: Meta tags y estructura semántica
- **Enfoque al usuario**: Contenido dirigido a músicos, grupos, salas de ensayo y conciertos

## 📦 Instalación

```bash
cd landing
npm install
```

## 🚀 Desarrollo

Para iniciar el servidor de desarrollo:

```bash
npm run dev
```

El sitio estará disponible en `http://localhost:4321`

## 🏗️ Build

Para crear la versión de producción:

```bash
npm run build
```

Los archivos optimizados se generarán en la carpeta `dist/`

## 📁 Estructura

```
landing/
├── src/
│   ├── components/       # Componentes de la página
│   │   ├── Hero.astro           # Sección hero principal
│   │   ├── Features.astro       # Características del producto
│   │   ├── TargetAudience.astro # Para quién es la plataforma
│   │   ├── HowItWorks.astro     # Cómo funciona (3 pasos)
│   │   ├── CTA.astro            # Call to action
│   │   └── Footer.astro         # Pie de página
│   ├── layouts/
│   │   └── Layout.astro  # Layout base
│   ├── pages/
│   │   └── index.astro   # Página principal
│   └── styles/
│       └── global.css    # Estilos globales y tokens
├── public/               # Archivos estáticos
├── astro.config.mjs
├── package.json
└── tsconfig.json
```

## 🎨 Secciones

### Hero

- Titular impactante con gradiente
- CTAs principales
- Estadísticas clave
- Tarjetas flotantes animadas

### Features

- 6 características principales
- Iconos animados
- Diseño en grid responsive

### Target Audience

- 4 tipos de usuarios (Músicos, Grupos, Salas de Ensayo, Salas de Conciertos)
- Beneficios específicos para cada uno
- Tarjetas con efecto hover

### How It Works

- Proceso en 3 pasos
- Números grandes y visuales
- Conectores animados (desktop)

### CTA

- Llamada a la acción final
- Elementos flotantes
- Efecto glassmorphism

### Footer

- Enlaces del sitio
- Redes sociales
- Información legal

## 🎨 Paleta de Colores

- **Primary**: `#8B5CF6` (Purple)
- **Secondary**: `#3B82F6` (Blue)
- **Accent**: `#EC4899` (Pink)
- **Background Dark**: `#0F172A`
- **Background Darker**: `#020617`

## 🔧 Personalización

Todos los tokens de diseño están centralizados en `src/styles/global.css`:

- Colores
- Espaciado
- Tipografía
- Sombras
- Border radius
- Transiciones

## 📝 Notas

- Las fuentes utilizadas son **Inter** (cuerpo) y **Outfit** (títulos) desde Google Fonts
- Los iconos son SVG inline de Heroicons
- Todas las animaciones están optimizadas para performance
- El diseño es dark mode por defecto para un look moderno y musical

## 🚀 Deploy

Esta landing page puede ser desplegada en cualquier servicio de hosting estático:

- Vercel
- Netlify
- Cloudflare Pages
- GitHub Pages

Simplemente ejecuta `npm run build` y sube la carpeta `dist/` al servicio de tu elección.
