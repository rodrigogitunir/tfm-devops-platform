
## CI/CD

Los cambios enviados a la rama main activan el pipeline de Jenkins mediante un webhook de GitHub. El despliegue automático se realiza en el entorno dev; pre y pro requieren aprobación.

## Validación automática del pipeline

El pipeline CI/CD se activa mediante un webhook de GitHub cuando se publican cambios en la rama main. El flujo ejecuta pruebas unitarias, construye y analiza la imagen Docker, carga la imagen en Minikube y valida el despliegue en el entorno dev.
