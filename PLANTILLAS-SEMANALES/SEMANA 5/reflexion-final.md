# Reflexión final de la primera etapa

# Reflexión final de la primera etapa

## Información del equipo

**Nombre del equipo:** Grupo 6

**Integrantes:**
- Jose Ballestas
- Daniel Gomez
- Nicolas Muvdi
- Francesco Rosa

---

## Lo que aprendimos del problema

¿Cómo cambió su comprensión del problema desde la semana 1 hasta la semana 5?

Al inicio percibíamos la falta de colaboración interinstitucional como un simple problema de desconexión entre facultades que se resolvía publicando anuncios. Con el paso de las semanas entendimos que el dolor real del estudiante radica en la fricción del primer contacto, la falta de visibilidad del nivel de compatibilidad en habilidades y la incertidumbre sobre las vacantes reales. Pasamos de ver una necesidad de "publicar proyectos" a resolver un problema de **matchmaking efectivo y gestión de expectativas** entre creadores y postulantes.

---

## Lo que aprendimos de la solución

¿Qué descubrieron sobre los flujos y la solución integrada que decidieron prototipar?

Descubrimos que la creación y la exploración de proyectos no pueden funcionar como módulos aislados. El flujo de publicación debe alimentarse directamente de los datos de perfil para sugerir vacantes de forma inteligente, mientras que la exploración necesita indicadores inmediatos (como el porcentaje de *% Match* y el conteo explícito de cupos) para evitar la sobrecarga de información. Integrar ambos flujos demostró que la claridad en la retroalimentación final (pantallas de confirmación de publicación y envío) es el factor clave para generar confianza en el usuario.

---

## Valor de la validación

¿Qué aportó validar primero versiones exploratorias y luego un prototipo más integrado antes de desarrollar una versión más completa?

Validar primero prototipos exploratorios nos permitió iterar rápido componentes específicos (como la selección por *tags* vs. casillas o el uso de *chips* de afinidad) sin gastar tiempo en estructurar toda la aplicación. Posteriormente, evaluar el prototipo integrado reveló problemas de continuidad entre pantallas e inconsistencias de contexto que nunca habríamos notado evaluando flujos por separado. Este enfoque gradual evitó que invirtiéramos esfuerzo en desarrollar interfaces o funciones innecesarias.

---

## Principal decisión

¿Cuál es la decisión más importante que toma el equipo después de esta etapa?

La decisión más importante es priorizar como núcleo del desarrollo un **motor de recomendación basado en perfiles y etiquetas dinámicas** (*tags*), acompañado de un sistema claro de retroalimentación de estados de solicitud, posponiendo características secundarias como chats en vivo o páneles complejos de administración hasta que la experiencia básica de postulación y emparejamiento esté totalmente consolidada.

---

## Conclusión final

Escriban un párrafo de 8 a 12 líneas respondiendo esta pregunta:

`¿Qué aprendió el equipo sobre diseñar una solución real antes de empezar a implementarla con más fuerza?`

A lo largo de este proceso, el equipo aprendió que diseñar una solución real exige poner a prueba las suposiciones teóricas frente a las reacciones genuinas de los usuarios antes de escribir una sola línea de código. Entendimos que la intuición inicial del desarrollador suele omitir pequeños detalles de usabilidad que resultan críticos para la experiencia del estudiante, como la necesidad de confirmaciones visuales explícitas o la preferencia por la búsqueda basada en etiquetas y afinidades. Prototipar de forma integrada nos demostró que una interfaz atractiva no sirve si los flujos no resuelven la incertidumbre del usuario al interactuar con el sistema. Esta etapa nos enseñó a priorizar las funciones que de verdad aportan valor, a descartar complejidades innecesarias y a encarar la fase de implementación técnica con una arquitectura visual y lógica sólida, ahorrando tiempo y reduciendo drásticamente el margen de error.
