# TaskFlow

Aplicación móvil nativa para iOS desarrollada en **Swift** y **SwiftUI** con arquitectura **MVVM** e integración en tiempo real con **Firebase Authentication** y **Cloud Firestore**, diseñada para la gestión colaborativa de proyectos y tareas por equipo.

## Datos Académicos
* **Estudiante:** Julio César García Avilés
* **Carnet:** 29-0402-2022
* **Asignatura:** ETPS4 — Ciclo 02-2026
* **Institución:** Universidad Tecnológica de El Salvador (UTEC)

## Características Principales
* **Autenticación y Perfiles:** Registro e inicio de sesión mediante Firebase Authentication con almacenamiento de perfil y rol (`Líder` / `Desarrollador`) en Cloud Firestore.
* **Gestión de Proyectos (`ProjectsView`):** Creación de proyectos colaborativos, vinculación de miembros (`memberIds`) y visualización sincronizada en tiempo real.
* **Control de Tareas y Estados:** Creación, asignación (`assigneeId`), prioridad y actualización instantánea de estados (`Por hacer`, `En progreso`, `Completada`) con contadores dinámicos y tachado automático.

## Requisitos de Configuración
1. Abrir `TaskFlow.xcodeproj` en **Xcode 14.2** o superior.
2. Agregar el archivo `GoogleService-Info.plist` de tu proyecto de Firebase dentro de la carpeta `TaskFlow/` (excluido del repositorio por seguridad).
3. Compilar y ejecutar en un simulador de iOS.
