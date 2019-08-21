# Findemes
Fuentes del programa Findemes: http://www.alanit.com/software/findemes/

**Findemes** es un programa de **contabilidad personal e inventario doméstico**. Permite almacenar información sobre ingresos y gastos, clasificandolos por categorías e identificando los pagadores y perceptores de los apuntes. Los apuntes por ejercicios, y dentro de cada ejercicio se pueden establecer multiples actividades, cada una de ellas con o sin seguimiento de IVA. Los apuntes de un ejercicio se pueden trabajar para todas las actividades o filtrados para cada actividad. También permite definir movimientos periódicos, tanto ingresos como gastos, que el programa ofrecerá para su anotación con la periodicidad adecuada. Incluye gestión de cuentas corrientes, pero no es obligatorio asignar los apuntes a cuentas. La contabilidad se completa con un módulo de gráficos que permite comparar la evolución de ingresos y gastos por meses o por categorías. El módulo de inventario permite inventariar los bienes u objetos que se desee, almacenando para cada uno de ellos el nombre del bien, marca, modelo, número de serie, categoría, ubicación, fecha de compra, fecha de garatía, importe, tienda, etiquetas, observaciones y una imagen del bien. El programa incorpora tablas de categorías, etiquetas, ubicaciones, marcas y tiendas.

Esta aplicación requiere Borland C, Harbour y FivewinHarbour para compilarse. Yo uso FWH 19.05 y la versión correspondiente de Harbour empaquetada por Fivetech. Para compilar el programa hay que make btc1905 que compila los fuentes y crea el ejecutable.

Mi editor es HippoEdit y el archivo findemes.heprj es el archivo de proyecto para ese editor.

La estructura de carpetas de la aplicación es la siguiente:

* ch - contiene archivos de cabecera del preprocesador
* 2013 - contiene datos de ejemplo del programa
* invent - datos de ejemplo del inventario
* makefile - contiene los archivos de compilación y enlazado
* prg - contiene los fuentes del programa. No están todos los fuentes debido a que uso modificaciones a medida de FivewinHarbour y esos fuentes no son públicos.

Para cualquier consulta escribirme a [joseluis@alanit.com](mailto:joseluis@alanit.com)

Novelda, agosto de 2019. José Luis Sánchez Navarro

![findemes3.50a](.\findemes3.50a.png)