CREATE TABLE tarefas (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    nome varchar NOT NULL,
    descricao varchar NOT NULL,
    feito boolean NOT NULL,
    criado_em timestamp without time zone NOT NULL DEFAULT now(),
    feito_em timestamp without time zone NULL,
    CONSTRAINT tarefas_pk PRIMARY KEY (id)
);
