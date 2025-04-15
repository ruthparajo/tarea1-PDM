Table parlamentarios {
  id integer [primary key]
  nombre_completo varchar
  partido_id integer
  inicio timestamp
  final timestamp
}

Table partidos {
  id integer [primary key]
  nombre varchar
}

Table intervenciones {
  id integer [primary key]
  parlamentario_id integer
  fecha timestamp
}

Table intervenciones_keywords {
  intervencion_id integer
  keyword_id integer
}

Table keywords {
  id integer
  palabra varchar
}

Ref : parlamentarios.partido_id > partidos.id

Ref : intervenciones.parlamentario_id > parlamentarios.id

Ref : intervenciones_keywords.intervencion_id > intervenciones.id

Ref : intervenciones_keywords.keyword_id > keywords.id