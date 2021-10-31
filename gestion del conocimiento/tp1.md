# TP Sparql

## Objetivo pedagógico
Utilizar Sparql para realizar consultas variadas en DBpedia.

## Requerimientos
Para este trabajo se requiere:
- Conexión a Internet para poder acceder al endpoint de DBpedia.

Como referencia para este trabajo, utilice el capítulo 6 (en particular de la sección 6.3 en adelante) del libro "Developers guide to the semantic web"

## Ejercicio 1: ¿Qué es dbpedia?
El siguiente articulo ofrece un panorama general de los aspectos más importantes de dbpedia http://svn.aksw.org/papers/2013/SWJ_DBpedia/public.pdf

Lea el artículo y responda:

1. _¿Qué es dbpedia?_

El proyecto de la comunidad DBpedia extrae conocimiento estructurado y multilingüe de Wikipedia y lo hace libremente disponible en la Web utilizando tecnologías de Web Semántica y Datos Vinculados. Este proyecto es realizado por la Universidad de Leipzig, Universidad Libre de Berlín y la compañía OpenLink Software.

2. _¿De donde sale la información disponible en dbpedia?_

El proyecto extrae conocimiento de 111 diferentes ediciones lingüísticas de Wikipedia. La base de conocimientos más grande de DBpedia que se extrae de la edición en inglés de Wikipedia consta de más de 400 millones de hechos que describen 3,7 millones de cosas. Las bases de conocimiento de DBpedia que se extraen del otro 110 ediciones de Wikipedia juntas constan de 1,46 mil millones de hechos y describen 10 millones de cosas adicionales. 

3. _¿Que partes de los artículos de Wikipedia se transforman en tripletas? ¿Qué prefijo utiliza DBpedia para sus propiedes y cuales para los recursos?_

Las partes de los articulos que se transforman en tripletas son los "infoboxes". La idea de estos infoboxes es que sean usados para mostrar los hechos mas importantes de un articulo en un formato de clave/valor. Existen distintas plantillas por los cuales son generados, por lo que esto simplifica la extraccion de la informacion.

TODO: esto que viene a continuacion difiere con el paper. el paper dice que los resources estan en dbr, pero la pagina ya no lo muestra.

DBpedia posee su ontologia en el prefijo `dbo`. Tambien posee los prefijos `dbp` y `dbd` para properties y datatypes respectivamente.
Para los recursos, los prefijos inician con `dbpedia-` y continua con el idioma, por ejemplo `dbpedia-es`.
Mas info [aqui](https://dbpedia.org/sparql/?help=nsdecl).

## Ejercicio 2: Realizar consultas Sparql en dbpedia
Para cada caso reporte la consulta sparql correspondiente y el resultado de la misma. En las consultas, de preferencia al uso de clases y propiedades en la ontología de dbpedia (dbo)

1. _Obtener a los escritores que hayan nacido en una ciudad de Argentina._

```sparql
SELECT ?item
WHERE 
{
    ?item rdf:type dbo:Person.
    ?item rdf:type dbo:Writer.
    ?item dbo:birthPlace ?lugar.
    ?lugar rdf:type dbo:City.
    ?lugar dbo:country dbr:Argentina.
}
```

| item.type | item.value                                                    |
| --------- | ------------------------------------------------------------- |
| uri       | http://dbpedia.org/resource/Héctor_Tizón                      |
| uri       | http://dbpedia.org/resource/Herman_Aguinis                    |
| uri       | http://dbpedia.org/resource/Gabriela_Cabezón_Cámara           |
| uri       | http://dbpedia.org/resource/Edgar_Brau                        |
| uri       | http://dbpedia.org/resource/Ángel_Cappelletti                 |
| uri       | http://dbpedia.org/resource/Alberto_Laiseca                   |
| uri       | http://dbpedia.org/resource/Ricardo_Ernesto_Montes_i_Bradley  |
| uri       | http://dbpedia.org/resource/Eduardo_Sguiglia                  |
| uri       | http://dbpedia.org/resource/Mirta_Rosenberg                   |
| uri       | http://dbpedia.org/resource/Enrique_Pavón_Pereyra             |
| uri       | http://dbpedia.org/resource/John_Farrell_(Australian_poet)    |
| uri       | http://dbpedia.org/resource/Jorge_Romero_Brest                |
| uri       | http://dbpedia.org/resource/Enrique_Larreta                   |
| uri       | http://dbpedia.org/resource/Elizabeth_Azcona_Cranwell         |
| uri       | http://dbpedia.org/resource/Esther_Vilar                      |
| uri       | http://dbpedia.org/resource/Marta_Lynch                       |
| uri       | http://dbpedia.org/resource/Marta_Mirazón_Lahr                |
| uri       | http://dbpedia.org/resource/Julio_Barragán                    |
| uri       | http://dbpedia.org/resource/Xavier_Waterkeyn                  |
| uri       | http://dbpedia.org/resource/Roberto_Arlt                      |
| uri       | http://dbpedia.org/resource/Jorge_Luis_Borges                 |
| uri       | http://dbpedia.org/resource/Sylvia_Molloy_(writer)            |
| uri       | http://dbpedia.org/resource/Lynette_Roberts                   |
| uri       | http://dbpedia.org/resource/Alejandro_Rozitchner              |
| uri       | http://dbpedia.org/resource/María_Esther_Vázquez              |
| uri       | http://dbpedia.org/resource/Mercedes_Ron                      |
| uri       | http://dbpedia.org/resource/Rafael_Squirru                    |
| uri       | http://dbpedia.org/resource/Martín_Caparrós                   |
| uri       | http://dbpedia.org/resource/Silvina_Bullrich                  |
| uri       | http://dbpedia.org/resource/Hugo_Mujica                       |
| uri       | http://dbpedia.org/resource/Bertha_Moss                       |
| uri       | http://dbpedia.org/resource/Ezechiel_Saad                     |
| uri       | http://dbpedia.org/resource/Pacho_O'Donnell                   |
| uri       | http://dbpedia.org/resource/Samanta_Schweblin                 |
| uri       | http://dbpedia.org/resource/Azucena_Galettini                 |
| uri       | http://dbpedia.org/resource/Adriana_Puiggrós                  |
| uri       | http://dbpedia.org/resource/Alan_Pauls                        |
| uri       | http://dbpedia.org/resource/Alejandro_Agostinelli             |
| uri       | http://dbpedia.org/resource/Aníbal_Cristobo                   |
| uri       | http://dbpedia.org/resource/Ariana_Harwicz                    |
| uri       | http://dbpedia.org/resource/Esteban_Echeverría                |
| uri       | http://dbpedia.org/resource/Federico_Andahazi                 |
| uri       | http://dbpedia.org/resource/Flavia_Company                    |
| uri       | http://dbpedia.org/resource/Oliver_Fiechter                   |
| uri       | http://dbpedia.org/resource/Carlos_Gorostiza                  |
| uri       | http://dbpedia.org/resource/Oliverio_Girondo                  |
| uri       | http://dbpedia.org/resource/Ángel_Faretta                     |
| uri       | http://dbpedia.org/resource/Guido_Mina_di_Sospiro             |
| uri       | http://dbpedia.org/resource/Adolfo_Bioy_Casares               |
| uri       | http://dbpedia.org/resource/Alberto_Manguel                   |
| uri       | http://dbpedia.org/resource/Ana_María_Shua                    |
| uri       | http://dbpedia.org/resource/Marta_Traba                       |
| uri       | http://dbpedia.org/resource/Marcelo_Birmajer                  |
| uri       | http://dbpedia.org/resource/Vicente_Fidel_López               |
| uri       | http://dbpedia.org/resource/Marcela_Iacub                     |
| uri       | http://dbpedia.org/resource/Conrado_Nalé_Roxlo                |
| uri       | http://dbpedia.org/resource/Humberto_Costantini               |
| uri       | http://dbpedia.org/resource/Gonzalo_Garcés                    |
| uri       | http://dbpedia.org/resource/Luis_Barragán_(painter)           |
| uri       | http://dbpedia.org/resource/Luisa_Peluffo                     |
| uri       | http://dbpedia.org/resource/Inés_Fernández_Moreno             |
| uri       | http://dbpedia.org/resource/J._Rodolfo_Wilcock                |
| uri       | http://dbpedia.org/resource/José_María_Rosa                   |
| uri       | http://dbpedia.org/resource/Carlos_Bernardo_González_Pecotche |
| uri       | http://dbpedia.org/resource/Carlos_Lousto                     |
| uri       | http://dbpedia.org/resource/Carlos_Petroni                    |
| uri       | http://dbpedia.org/resource/José_María_Ramos_Mejía            |
| uri       | http://dbpedia.org/resource/José_Rivera_Indarte               |
| uri       | http://dbpedia.org/resource/Enrique_Anderson_Imbert           |
| uri       | http://dbpedia.org/resource/Perla_Suez                        |
| uri       | http://dbpedia.org/resource/Alicia_Ghiragossian               |
| uri       | http://dbpedia.org/resource/Marcos_Aguinis                    |
| uri       | http://dbpedia.org/resource/Felipe_Pigna                      |
| uri       | http://dbpedia.org/resource/Lohana_Berkins                    |
| uri       | http://dbpedia.org/resource/Homero_Manzi                      |
| uri       | http://dbpedia.org/resource/Mario_Markic                      |
| uri       | http://dbpedia.org/resource/Ricardo_Romero_(writer)           |
| uri       | http://dbpedia.org/resource/César_Aira                        |
| uri       | http://dbpedia.org/resource/María_Elena_Walsh                 |
| uri       | http://dbpedia.org/resource/Raúl_Scalabrini_Ortiz             |
| uri       | http://dbpedia.org/resource/Emma_de_Cartosio                  |
| uri       | http://dbpedia.org/resource/Martina_Iñíguez                   |

2. _Obtener a los escritores que hayan nacido en una ciudad de Uruguay._

```sparql
SELECT ?item
WHERE 
{
    ?item rdf:type dbo:Person.
    ?item rdf:type dbo:Writer.
    ?item dbo:birthPlace ?lugar.
    ?lugar rdf:type dbo:City.
    ?lugar dbo:country dbr:Uruguay.
}
```

| item.type | item.value                                          |
| --------- | --------------------------------------------------- |
| uri       | http://dbpedia.org/resource/Claudia_Amengual        |
| uri       | http://dbpedia.org/resource/Delmira_Agustini        |
| uri       | http://dbpedia.org/resource/José_Enrique_Rodó       |
| uri       | http://dbpedia.org/resource/Juan_Carlos_Onetti      |
| uri       | http://dbpedia.org/resource/Julio_Herrera_y_Reissig |
| uri       | http://dbpedia.org/resource/Jorge_Ruffinelli        |
| uri       | http://dbpedia.org/resource/Marcos_Sastre           |
| uri       | http://dbpedia.org/resource/Manuel_Pérez_y_Curis    |
| uri       | http://dbpedia.org/resource/Esther_de_Cáceres       |
| uri       | http://dbpedia.org/resource/Mario_Benedetti         |
| uri       | http://dbpedia.org/resource/Gabriel_Pombo           |
| uri       | http://dbpedia.org/resource/Jules_Supervielle       |
| uri       | http://dbpedia.org/resource/Daniel_Chavarría        |
| uri       | http://dbpedia.org/resource/Daniel_Mella            |
| uri       | http://dbpedia.org/resource/Ida_Vitale              |
| uri       | http://dbpedia.org/resource/Jorge_Majfud            |
| uri       | http://dbpedia.org/resource/Adela_Castell           |
| uri       | http://dbpedia.org/resource/Jorge_Medina_Vidal      |
| uri       | http://dbpedia.org/resource/Hugo_Burel              |
| uri       | http://dbpedia.org/resource/Alberto_Methol_Ferré    |
| uri       | http://dbpedia.org/resource/Eduardo_Acevedo_Díaz    |
| uri       | http://dbpedia.org/resource/Eduardo_Galeano         |
| uri       | http://dbpedia.org/resource/Laura_Canoura           |
| uri       | http://dbpedia.org/resource/Comte_de_Lautréamont    |
| uri       | http://dbpedia.org/resource/Eduardo_Cuitiño         |
| uri       | http://dbpedia.org/resource/Natalia_Mardero         |
| uri       | http://dbpedia.org/resource/Circe_Maia              |
| uri       | http://dbpedia.org/resource/Gloria_Escomel          |
| uri       | http://dbpedia.org/resource/Juan_Carlos_Mondragón   |
| uri       | http://dbpedia.org/resource/Jules_Laforgue          |
| uri       | http://dbpedia.org/resource/Carlos_Rehermann        |
| uri       | http://dbpedia.org/resource/Carlos_Vaz_Ferreira     |
| uri       | http://dbpedia.org/resource/Carmen_Novoa            |
| uri       | http://dbpedia.org/resource/Carmen_Posadas          |
| uri       | http://dbpedia.org/resource/Matilde_Bianchi         |
| uri       | http://dbpedia.org/resource/Hipólito_da_Costa       |
| uri       | http://dbpedia.org/resource/Luisa_Luisi             |

3. _Utilizando el keyword filter (vea sección 6.3.2.6 del libro), obtener a los escritores que hayan nacido en una ciudad de Argentina o de Uruguay_

```sparql
SELECT ?item
WHERE 
{
    ?item rdf:type dbo:Person.
    ?item rdf:type dbo:Writer.
    ?item dbo:birthPlace ?lugar.
    ?lugar rdf:type dbo:City.
    ?lugar dbo:country ?pais.
    FILTER(?pais = dbr:Argentina || ?pais = dbr:Uruguay)
}
```

| item.type | item.value                                                    |
| --------- | ------------------------------------------------------------- |
| uri       | http://dbpedia.org/resource/Héctor_Tizón                      |
| uri       | http://dbpedia.org/resource/Herman_Aguinis                    |
| uri       | http://dbpedia.org/resource/Gabriela_Cabezón_Cámara           |
| uri       | http://dbpedia.org/resource/Edgar_Brau                        |
| uri       | http://dbpedia.org/resource/Ángel_Cappelletti                 |
| uri       | http://dbpedia.org/resource/Alberto_Laiseca                   |
| uri       | http://dbpedia.org/resource/Ricardo_Ernesto_Montes_i_Bradley  |
| uri       | http://dbpedia.org/resource/Eduardo_Sguiglia                  |
| uri       | http://dbpedia.org/resource/Mirta_Rosenberg                   |
| uri       | http://dbpedia.org/resource/Daniel_Chavarría                  |
| uri       | http://dbpedia.org/resource/Enrique_Pavón_Pereyra             |
| uri       | http://dbpedia.org/resource/Mario_Benedetti                   |
| uri       | http://dbpedia.org/resource/John_Farrell_(Australian_poet)    |
| uri       | http://dbpedia.org/resource/Jorge_Romero_Brest                |
| uri       | http://dbpedia.org/resource/Enrique_Larreta                   |
| uri       | http://dbpedia.org/resource/Elizabeth_Azcona_Cranwell         |
| uri       | http://dbpedia.org/resource/Esther_Vilar                      |
| uri       | http://dbpedia.org/resource/Marta_Lynch                       |
| uri       | http://dbpedia.org/resource/Marta_Mirazón_Lahr                |
| uri       | http://dbpedia.org/resource/Julio_Barragán                    |
| uri       | http://dbpedia.org/resource/Xavier_Waterkeyn                  |
| uri       | http://dbpedia.org/resource/Roberto_Arlt                      |
| uri       | http://dbpedia.org/resource/Jorge_Luis_Borges                 |
| uri       | http://dbpedia.org/resource/Sylvia_Molloy_(writer)            |
| uri       | http://dbpedia.org/resource/Lynette_Roberts                   |
| uri       | http://dbpedia.org/resource/Alejandro_Rozitchner              |
| uri       | http://dbpedia.org/resource/María_Esther_Vázquez              |
| uri       | http://dbpedia.org/resource/Mercedes_Ron                      |
| uri       | http://dbpedia.org/resource/Rafael_Squirru                    |
| uri       | http://dbpedia.org/resource/Martín_Caparrós                   |
| uri       | http://dbpedia.org/resource/Silvina_Bullrich                  |
| uri       | http://dbpedia.org/resource/Hugo_Mujica                       |
| uri       | http://dbpedia.org/resource/Bertha_Moss                       |
| uri       | http://dbpedia.org/resource/Ezechiel_Saad                     |
| uri       | http://dbpedia.org/resource/Pacho_O'Donnell                   |
| uri       | http://dbpedia.org/resource/Samanta_Schweblin                 |
| uri       | http://dbpedia.org/resource/Azucena_Galettini                 |
| uri       | http://dbpedia.org/resource/Adriana_Puiggrós                  |
| uri       | http://dbpedia.org/resource/Alan_Pauls                        |
| uri       | http://dbpedia.org/resource/Alejandro_Agostinelli             |
| uri       | http://dbpedia.org/resource/Aníbal_Cristobo                   |
| uri       | http://dbpedia.org/resource/Ariana_Harwicz                    |
| uri       | http://dbpedia.org/resource/Esteban_Echeverría                |
| uri       | http://dbpedia.org/resource/Federico_Andahazi                 |
| uri       | http://dbpedia.org/resource/Flavia_Company                    |
| uri       | http://dbpedia.org/resource/Oliver_Fiechter                   |
| uri       | http://dbpedia.org/resource/Carlos_Gorostiza                  |
| uri       | http://dbpedia.org/resource/Oliverio_Girondo                  |
| uri       | http://dbpedia.org/resource/Ángel_Faretta                     |
| uri       | http://dbpedia.org/resource/Guido_Mina_di_Sospiro             |
| uri       | http://dbpedia.org/resource/Adolfo_Bioy_Casares               |
| uri       | http://dbpedia.org/resource/Alberto_Manguel                   |
| uri       | http://dbpedia.org/resource/Ana_María_Shua                    |
| uri       | http://dbpedia.org/resource/Marta_Traba                       |
| uri       | http://dbpedia.org/resource/Marcelo_Birmajer                  |
| uri       | http://dbpedia.org/resource/Vicente_Fidel_López               |
| uri       | http://dbpedia.org/resource/Marcela_Iacub                     |
| uri       | http://dbpedia.org/resource/Conrado_Nalé_Roxlo                |
| uri       | http://dbpedia.org/resource/Humberto_Costantini               |
| uri       | http://dbpedia.org/resource/Gonzalo_Garcés                    |
| uri       | http://dbpedia.org/resource/Luis_Barragán_(painter)           |
| uri       | http://dbpedia.org/resource/Luisa_Peluffo                     |
| uri       | http://dbpedia.org/resource/Inés_Fernández_Moreno             |
| uri       | http://dbpedia.org/resource/J._Rodolfo_Wilcock                |
| uri       | http://dbpedia.org/resource/José_María_Rosa                   |
| uri       | http://dbpedia.org/resource/Carlos_Bernardo_González_Pecotche |
| uri       | http://dbpedia.org/resource/Carlos_Lousto                     |
| uri       | http://dbpedia.org/resource/Carlos_Petroni                    |
| uri       | http://dbpedia.org/resource/José_María_Ramos_Mejía            |
| uri       | http://dbpedia.org/resource/Jorge_Majfud                      |
| uri       | http://dbpedia.org/resource/José_Rivera_Indarte               |
| uri       | http://dbpedia.org/resource/Enrique_Anderson_Imbert           |
| uri       | http://dbpedia.org/resource/Perla_Suez                        |
| uri       | http://dbpedia.org/resource/Alicia_Ghiragossian               |
| uri       | http://dbpedia.org/resource/Marcos_Aguinis                    |
| uri       | http://dbpedia.org/resource/Felipe_Pigna                      |
| uri       | http://dbpedia.org/resource/Lohana_Berkins                    |
| uri       | http://dbpedia.org/resource/Homero_Manzi                      |
| uri       | http://dbpedia.org/resource/Claudia_Amengual                  |
| uri       | http://dbpedia.org/resource/Delmira_Agustini                  |
| uri       | http://dbpedia.org/resource/José_Enrique_Rodó                 |
| uri       | http://dbpedia.org/resource/Juan_Carlos_Onetti                |
| uri       | http://dbpedia.org/resource/Julio_Herrera_y_Reissig           |
| uri       | http://dbpedia.org/resource/Jorge_Ruffinelli                  |
| uri       | http://dbpedia.org/resource/Marcos_Sastre                     |
| uri       | http://dbpedia.org/resource/Manuel_Pérez_y_Curis              |
| uri       | http://dbpedia.org/resource/Esther_de_Cáceres                 |
| uri       | http://dbpedia.org/resource/Gabriel_Pombo                     |
| uri       | http://dbpedia.org/resource/Jules_Supervielle                 |
| uri       | http://dbpedia.org/resource/Daniel_Mella                      |
| uri       | http://dbpedia.org/resource/Ida_Vitale                        |
| uri       | http://dbpedia.org/resource/Jorge_Medina_Vidal                |
| uri       | http://dbpedia.org/resource/Hugo_Burel                        |
| uri       | http://dbpedia.org/resource/Alberto_Methol_Ferré              |
| uri       | http://dbpedia.org/resource/Eduardo_Acevedo_Díaz              |
| uri       | http://dbpedia.org/resource/Eduardo_Galeano                   |
| uri       | http://dbpedia.org/resource/Laura_Canoura                     |
| uri       | http://dbpedia.org/resource/Comte_de_Lautréamont              |
| uri       | http://dbpedia.org/resource/Eduardo_Cuitiño                   |
| uri       | http://dbpedia.org/resource/Natalia_Mardero                   |
| uri       | http://dbpedia.org/resource/Circe_Maia                        |
| uri       | http://dbpedia.org/resource/Gloria_Escomel                    |
| uri       | http://dbpedia.org/resource/Juan_Carlos_Mondragón             |
| uri       | http://dbpedia.org/resource/Jules_Laforgue                    |
| uri       | http://dbpedia.org/resource/Carlos_Rehermann                  |
| uri       | http://dbpedia.org/resource/Carlos_Vaz_Ferreira               |
| uri       | http://dbpedia.org/resource/Carmen_Novoa                      |
| uri       | http://dbpedia.org/resource/Carmen_Posadas                    |
| uri       | http://dbpedia.org/resource/Matilde_Bianchi                   |
| uri       | http://dbpedia.org/resource/Mario_Markic                      |
| uri       | http://dbpedia.org/resource/Ricardo_Romero_(writer)           |
| uri       | http://dbpedia.org/resource/Adela_Castell                     |
| uri       | http://dbpedia.org/resource/Luisa_Luisi                       |
| uri       | http://dbpedia.org/resource/César_Aira                        |
| uri       | http://dbpedia.org/resource/María_Elena_Walsh                 |
| uri       | http://dbpedia.org/resource/Raúl_Scalabrini_Ortiz             |
| uri       | http://dbpedia.org/resource/Emma_de_Cartosio                  |
| uri       | http://dbpedia.org/resource/Martina_Iñíguez                   |
| uri       | http://dbpedia.org/resource/Hipólito_da_Costa                 |

4. _Utilizando el keyword union (vea sección 6.3.2.6 del libro), obtener a los escritores que hayan nacido en una ciudad de Argentina o de Uruguay_

```sparql
SELECT *
WHERE 
{
    {
        SELECT ?item
        WHERE 
        {
            ?item rdf:type dbo:Person.
            ?item rdf:type dbo:Writer.
            ?item dbo:birthPlace ?lugar.
            ?lugar rdf:type dbo:City.
            ?lugar dbo:country dbr:Argentina.
        }
    }
    UNION
    {
        SELECT ?item
        WHERE 
        {
            ?item rdf:type dbo:Person.
            ?item rdf:type dbo:Writer.
            ?item dbo:birthPlace ?lugar2.
            ?lugar2 rdf:type dbo:City.
            ?lugar2 dbo:country dbr:Uruguay.
        }
    }
}
```

| item.type | item.value                                                    |
| --------- | ------------------------------------------------------------- |
| uri       | http://dbpedia.org/resource/Héctor_Tizón                      |
| uri       | http://dbpedia.org/resource/Herman_Aguinis                    |
| uri       | http://dbpedia.org/resource/Gabriela_Cabezón_Cámara           |
| uri       | http://dbpedia.org/resource/Edgar_Brau                        |
| uri       | http://dbpedia.org/resource/Ángel_Cappelletti                 |
| uri       | http://dbpedia.org/resource/Alberto_Laiseca                   |
| uri       | http://dbpedia.org/resource/Ricardo_Ernesto_Montes_i_Bradley  |
| uri       | http://dbpedia.org/resource/Eduardo_Sguiglia                  |
| uri       | http://dbpedia.org/resource/Mirta_Rosenberg                   |
| uri       | http://dbpedia.org/resource/Enrique_Pavón_Pereyra             |
| uri       | http://dbpedia.org/resource/John_Farrell_(Australian_poet)    |
| uri       | http://dbpedia.org/resource/Jorge_Romero_Brest                |
| uri       | http://dbpedia.org/resource/Enrique_Larreta                   |
| uri       | http://dbpedia.org/resource/Elizabeth_Azcona_Cranwell         |
| uri       | http://dbpedia.org/resource/Esther_Vilar                      |
| uri       | http://dbpedia.org/resource/Marta_Lynch                       |
| uri       | http://dbpedia.org/resource/Marta_Mirazón_Lahr                |
| uri       | http://dbpedia.org/resource/Julio_Barragán                    |
| uri       | http://dbpedia.org/resource/Xavier_Waterkeyn                  |
| uri       | http://dbpedia.org/resource/Roberto_Arlt                      |
| uri       | http://dbpedia.org/resource/Jorge_Luis_Borges                 |
| uri       | http://dbpedia.org/resource/Sylvia_Molloy_(writer)            |
| uri       | http://dbpedia.org/resource/Lynette_Roberts                   |
| uri       | http://dbpedia.org/resource/Alejandro_Rozitchner              |
| uri       | http://dbpedia.org/resource/María_Esther_Vázquez              |
| uri       | http://dbpedia.org/resource/Mercedes_Ron                      |
| uri       | http://dbpedia.org/resource/Rafael_Squirru                    |
| uri       | http://dbpedia.org/resource/Martín_Caparrós                   |
| uri       | http://dbpedia.org/resource/Silvina_Bullrich                  |
| uri       | http://dbpedia.org/resource/Hugo_Mujica                       |
| uri       | http://dbpedia.org/resource/Bertha_Moss                       |
| uri       | http://dbpedia.org/resource/Ezechiel_Saad                     |
| uri       | http://dbpedia.org/resource/Pacho_O'Donnell                   |
| uri       | http://dbpedia.org/resource/Samanta_Schweblin                 |
| uri       | http://dbpedia.org/resource/Azucena_Galettini                 |
| uri       | http://dbpedia.org/resource/Adriana_Puiggrós                  |
| uri       | http://dbpedia.org/resource/Alan_Pauls                        |
| uri       | http://dbpedia.org/resource/Alejandro_Agostinelli             |
| uri       | http://dbpedia.org/resource/Aníbal_Cristobo                   |
| uri       | http://dbpedia.org/resource/Ariana_Harwicz                    |
| uri       | http://dbpedia.org/resource/Esteban_Echeverría                |
| uri       | http://dbpedia.org/resource/Federico_Andahazi                 |
| uri       | http://dbpedia.org/resource/Flavia_Company                    |
| uri       | http://dbpedia.org/resource/Oliver_Fiechter                   |
| uri       | http://dbpedia.org/resource/Carlos_Gorostiza                  |
| uri       | http://dbpedia.org/resource/Oliverio_Girondo                  |
| uri       | http://dbpedia.org/resource/Ángel_Faretta                     |
| uri       | http://dbpedia.org/resource/Guido_Mina_di_Sospiro             |
| uri       | http://dbpedia.org/resource/Adolfo_Bioy_Casares               |
| uri       | http://dbpedia.org/resource/Alberto_Manguel                   |
| uri       | http://dbpedia.org/resource/Ana_María_Shua                    |
| uri       | http://dbpedia.org/resource/Marta_Traba                       |
| uri       | http://dbpedia.org/resource/Marcelo_Birmajer                  |
| uri       | http://dbpedia.org/resource/Vicente_Fidel_López               |
| uri       | http://dbpedia.org/resource/Marcela_Iacub                     |
| uri       | http://dbpedia.org/resource/Conrado_Nalé_Roxlo                |
| uri       | http://dbpedia.org/resource/Humberto_Costantini               |
| uri       | http://dbpedia.org/resource/Gonzalo_Garcés                    |
| uri       | http://dbpedia.org/resource/Luis_Barragán_(painter)           |
| uri       | http://dbpedia.org/resource/Luisa_Peluffo                     |
| uri       | http://dbpedia.org/resource/Inés_Fernández_Moreno             |
| uri       | http://dbpedia.org/resource/J._Rodolfo_Wilcock                |
| uri       | http://dbpedia.org/resource/José_María_Rosa                   |
| uri       | http://dbpedia.org/resource/Carlos_Bernardo_González_Pecotche |
| uri       | http://dbpedia.org/resource/Carlos_Lousto                     |
| uri       | http://dbpedia.org/resource/Carlos_Petroni                    |
| uri       | http://dbpedia.org/resource/José_María_Ramos_Mejía            |
| uri       | http://dbpedia.org/resource/José_Rivera_Indarte               |
| uri       | http://dbpedia.org/resource/Enrique_Anderson_Imbert           |
| uri       | http://dbpedia.org/resource/Perla_Suez                        |
| uri       | http://dbpedia.org/resource/Alicia_Ghiragossian               |
| uri       | http://dbpedia.org/resource/Marcos_Aguinis                    |
| uri       | http://dbpedia.org/resource/Felipe_Pigna                      |
| uri       | http://dbpedia.org/resource/Lohana_Berkins                    |
| uri       | http://dbpedia.org/resource/Homero_Manzi                      |
| uri       | http://dbpedia.org/resource/Mario_Markic                      |
| uri       | http://dbpedia.org/resource/Ricardo_Romero_(writer)           |
| uri       | http://dbpedia.org/resource/César_Aira                        |
| uri       | http://dbpedia.org/resource/María_Elena_Walsh                 |
| uri       | http://dbpedia.org/resource/Raúl_Scalabrini_Ortiz             |
| uri       | http://dbpedia.org/resource/Emma_de_Cartosio                  |
| uri       | http://dbpedia.org/resource/Martina_Iñíguez                   |
| uri       | http://dbpedia.org/resource/Claudia_Amengual                  |
| uri       | http://dbpedia.org/resource/Delmira_Agustini                  |
| uri       | http://dbpedia.org/resource/José_Enrique_Rodó                 |
| uri       | http://dbpedia.org/resource/Juan_Carlos_Onetti                |
| uri       | http://dbpedia.org/resource/Julio_Herrera_y_Reissig           |
| uri       | http://dbpedia.org/resource/Jorge_Ruffinelli                  |
| uri       | http://dbpedia.org/resource/Marcos_Sastre                     |
| uri       | http://dbpedia.org/resource/Manuel_Pérez_y_Curis              |
| uri       | http://dbpedia.org/resource/Esther_de_Cáceres                 |
| uri       | http://dbpedia.org/resource/Mario_Benedetti                   |
| uri       | http://dbpedia.org/resource/Gabriel_Pombo                     |
| uri       | http://dbpedia.org/resource/Jules_Supervielle                 |
| uri       | http://dbpedia.org/resource/Daniel_Chavarría                  |
| uri       | http://dbpedia.org/resource/Daniel_Mella                      |
| uri       | http://dbpedia.org/resource/Ida_Vitale                        |
| uri       | http://dbpedia.org/resource/Jorge_Majfud                      |
| uri       | http://dbpedia.org/resource/Adela_Castell                     |
| uri       | http://dbpedia.org/resource/Jorge_Medina_Vidal                |
| uri       | http://dbpedia.org/resource/Hugo_Burel                        |
| uri       | http://dbpedia.org/resource/Alberto_Methol_Ferré              |
| uri       | http://dbpedia.org/resource/Eduardo_Acevedo_Díaz              |
| uri       | http://dbpedia.org/resource/Eduardo_Galeano                   |
| uri       | http://dbpedia.org/resource/Laura_Canoura                     |
| uri       | http://dbpedia.org/resource/Comte_de_Lautréamont              |
| uri       | http://dbpedia.org/resource/Eduardo_Cuitiño                   |
| uri       | http://dbpedia.org/resource/Natalia_Mardero                   |
| uri       | http://dbpedia.org/resource/Circe_Maia                        |
| uri       | http://dbpedia.org/resource/Gloria_Escomel                    |
| uri       | http://dbpedia.org/resource/Juan_Carlos_Mondragón             |
| uri       | http://dbpedia.org/resource/Jules_Laforgue                    |
| uri       | http://dbpedia.org/resource/Carlos_Rehermann                  |
| uri       | http://dbpedia.org/resource/Carlos_Vaz_Ferreira               |
| uri       | http://dbpedia.org/resource/Carmen_Novoa                      |
| uri       | http://dbpedia.org/resource/Carmen_Posadas                    |
| uri       | http://dbpedia.org/resource/Matilde_Bianchi                   |
| uri       | http://dbpedia.org/resource/Hipólito_da_Costa                 |
| uri       | http://dbpedia.org/resource/Luisa_Luisi                       |


## Ejercicio 3: Llegó Wikidata
Acceda al sitio oficial del proyecto Wikidata: https://www.wikidata.org y leyendo la documentación responda las siguientes preguntas.

1. _¿Qué es wikidata?_

Wikidata es una base de conocimiento colaborativa, libre y abierta que almacena información estructurada. Su principal ventaja es que ofrece datos enlazados, descritos mediante RDF, lo cual permite relacionarlos con otros conjuntos de datos de otros repositorios digitales.
Wikidata puede ser leída y editada tanto por seres humanos como por máquinas, integrando fuentes de datos publicadas con licencias compatibles con Creative Commons de dominio público (CC-0). Por tanto, todo el contenido puede ser reutilizado por cualquier persona u empresa que así lo desee.

2. _¿De donde sale la información disponible en Wikidata?_

Los datos se obtienen de las siguientes fuentes:
- Wikipedia – Encyclopedia  
- Wiktionary – Dictionary and thesaurus    
- Wikibooks – Textbooks, manuals, and cookbooks   
- Wikinews – News   
- Wikiquote – Collection of quotations    
- Wikisource – Library    
- Wikiversity – Learning resources    
- Wikivoyage – Travel guides    
- Wikispecies – Directory of species   
- Wikimedia Commons – Media repository    
- Incubator – New language versions   
- Meta-Wiki – Wikimedia project coordination   
- MediaWiki – Software documentation   

3. _¿Que partes de los artículos de Wikipedia se transforman en tripletas?_

Cualquier informacion del articulo puede ser convertido en tripletas. De hecho, como se menciona en [la pagina de wikimedia](https://meta.wikimedia.org/wiki/Wikidata/Notes/DBpedia_and_Wikidata), mientras que dbpedia extrae la informacion "semi estructurada" de los infoboxes y los expone en tripletas, wikidata permite generar los infoboxes con sus tripletas. Es por esto que la generacion de las mismas es "semi manual" mientras que la de dbpedia es mas "automatica".

4. _¿Dado el articulo en Wikipedia de "National University of La Plata", como infiero la URL del recurso correspondiente en Wikidata?_

Cuando entramos a la url del recurso (https://es.wikipedia.org/wiki/Universidad_Nacional_de_La_Plata), en la seccion inferior podemos encontrar una seccion "Control de Autoridades" donde se encuentra el link a Wikidata (https://www.wikidata.org/wiki/Q784171).

![seccion-control-autoridades](ubicacion_url_wikidata.png) 

5. _¿Que diferencias y similitudes encuentra con DBpedia?_

Ambas presentan la informacion de wikipedia de una forma estructurada, basada en grafos.

Las principales diferencias para destacar:
- **Dirección del flujo de información**: DBpedia extrae información de Wikipedia, Wikidata la proporciona a Wikipedia.
- **Estructura**: DBpedia hace lo mejor para aplicar estructura a la información textual de Wikipedia, mientras que la información de Wikidata está estructurada de forma nativa para comenzar.
- **Madurez**: DBpedia es más antigua, Wikidata recién está comenzando.
- **Automatizacion**: DBpedia posee un proceso de extraccion de informacion automatizado ya que utiliza la informacion de los infoboxes, mientras que Wikidata es semi-automatica/depediente de la comunidad que la mantiene.

## Ejercicio 4: Consultas en Wikidata
1. _Adapte las queries que construyo en los puntos c y d del ejercicio anterior en el endpoint de Wikidata. (https://query.wikidata.org). ¿Obtuvo resultados diferentes? Si la respuesta es si, ¿a que se deben?_

```sparql
# escritores que hayan nacido en una ciudad de Argentina o de Uruguay usando filter
SELECT ?item ?itemLabel
WHERE
{
  ?item wdt:P31 wd:Q5. # instanceof human
  ?item wdt:P106 wd:Q36180. # occupation writer
  ?item wdt:P19 ?lugar. # placeOfBirth 
  ?lugar wdt:P31 wd:Q515. # instanceof city
  ?lugar wdt:P17 ?pais. # country
  SERVICE wikibase:label { bd:serviceParam wikibase:language "en" }
  FILTER(?pais = wd:Q414 || ?pais = wd:Q77) # argentina || uruguay
}
```

```sparql
# escritores que hayan nacido en una ciudad de Argentina o de Uruguay usando union
SELECT * 
WHERE
{
  {
    SELECT ?item ?itemLabel
    WHERE
    {
      ?item wdt:P31 wd:Q5. # instanceof human
      ?item wdt:P106 wd:Q36180. # occupation writer
      ?item wdt:P19 ?lugar. # placeOfBirth 
      ?lugar wdt:P31 wd:Q515. # instanceof city
      ?lugar wdt:P17 wd:Q414. # country argentina
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en" }
    }
  }
  UNION
  {
    SELECT ?item ?itemLabel
    WHERE
    {
      ?item wdt:P31 wd:Q5. # instanceof human
      ?item wdt:P106 wd:Q36180. # occupation writer
      ?item wdt:P19 ?lugar. # placeOfBirth 
      ?lugar wdt:P31 wd:Q515. # instanceof city
      ?lugar wdt:P17 wd:Q77. # country uruguay
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en" }
    }
  }
}
```
A comparacion de las queries realizadas en dbpedia, estas devuelven un total de `1796` registros.
Esto puede deberse no solo a que poseen estructuras de grafos distintas, sino que tambien wikidata posee la mayor parte de la wikipedia mientras que dbpedia no.

2. _Realice una mapa en la que sea posible visualizar los autódromos que se encuentran en una ciudad que esté a mas de 600 metros sobre el nivel del mar._

```sparql
SELECT ?item ?itemLabel ?geo
WHERE 
{
  ?item wdt:P31 wd:Q2338524. # instanceof motorsportRacingTrack
  ?item wdt:P131 ?lugar. # located
  ?item wdt:P625 ?geo. # coordinateLocation
  ?lugar wdt:P31 wd:Q515. # instanceof city
  ?lugar wdt:P2044 ?elevacion. # elevationAboveSeaLevel
  SERVICE wikibase:label { bd:serviceParam wikibase:language "en" }
  FILTER(?elevacion >= 600)
}
```

| item                                     | itemLabel                    | geo                               |
| ---------------------------------------- | ---------------------------- | --------------------------------- |
| http://www.wikidata.org/entity/Q867557   | Circuito de Albacete         | Point(-1.79416667 39.00638889)    |
| http://www.wikidata.org/entity/Q4827227  | Autódromo Jorge Ángel Pena   | Point(-68.49741667 -33.05983333)  |
| http://www.wikidata.org/entity/Q12156002 | Autódromo Las Vizcachas      | Point(-70.52263333 -33.60229167)  |
| http://www.wikidata.org/entity/Q173099   | Autódromo Hermanos Rodríguez | Point(-99.088747222 19.404197222) |

Y en el mapa:

![mapa](mapa.png)
