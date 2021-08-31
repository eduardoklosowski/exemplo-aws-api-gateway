import json
import os
from dataclasses import dataclass
from datetime import datetime
from typing import Optional
from uuid import UUID

import psycopg2

DATETIME_FMT = '%Y-%m-%dT%H:%M:%S.%f'
SQL_INSERT = '''
    INSERT INTO tarefas (nome, descricao, feito, feito_em)
    VALUES (%s, %s, %s, %s)
    RETURNING id, nome, descricao, feito, criado_em, feito_em
'''
SQL_SELECT_ALL = '''
    SELECT id, nome, descricao, feito, criado_em, feito_em
    FROM tarefas
    ORDER BY criado_em ASC
'''
SQL_SELECT = '''
    SELECT id, nome, descricao, feito, criado_em, feito_em
    FROM tarefas
    WHERE id = %s
'''
SQL_UPDATE = '''
    UPDATE tarefas
    SET nome = %s, descricao = %s, feito = %s, feito_em = %s
    WHERE id = %s
    RETURNING id, nome, descricao, feito, criado_em, feito_em
'''
SQL_DELETE = '''
    DELETE FROM tarefas
    WHERE id = %s
'''


def pg_connect():
    return psycopg2.connect(os.environ['PG_DSN'])


@dataclass
class Tarefa:
    id: UUID
    nome: str
    descricao: str
    feito: bool
    criado_em: datetime
    feito_em: Optional[datetime]

    def __iter__(self):
        yield 'id', str(self.id)
        yield 'nome', self.nome
        yield 'descricao', self.descricao
        yield 'feito', self.feito
        yield 'criadoEm', self.criado_em.strftime(DATETIME_FMT)
        yield 'feitoEm', (
            self.feito_em.strftime(DATETIME_FMT)
            if self.feito_em is not None else None
        )


def add_tarefa(event, context):
    body = json.loads(event['body'])
    conn = pg_connect()
    cur = conn.cursor()

    cur.execute(
        SQL_INSERT, (
            body['nome'],
            body['descricao'],
            body['feito'],
            datetime.now() if body['feito'] else None,
        ),
    )
    tarefa = cur.fetchone()

    conn.commit()
    cur.close()
    conn.close()

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
        },
        'body': json.dumps(dict(Tarefa(*tarefa))),
    }


def list_tarefa(event, context):
    conn = pg_connect()
    cur = conn.cursor()

    cur.execute(SQL_SELECT_ALL)
    tarefas = cur.fetchall()

    cur.close()
    conn.close()

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
        },
        'body': json.dumps([dict(Tarefa(*tarefa)) for tarefa in tarefas]),
    }


def get_tarefa(event, contenxt):
    conn = pg_connect()
    cur = conn.cursor()

    cur.execute(
        SQL_SELECT, (
            event['pathParameters']['id+'],
        ),
    )
    tarefa = cur.fetchone()

    cur.close()
    conn.close()

    if tarefa is None:
        return {
            'statusCode': 404,
        }
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
        },
        'body': json.dumps(dict(Tarefa(*tarefa))),
    }


def edit_tarefa(event, contenxt):
    body = json.loads(event['body'])
    conn = pg_connect()
    cur = conn.cursor()

    cur.execute(
        SQL_UPDATE, (
            body['nome'],
            body['descricao'],
            body['feito'],
            datetime.now() if body['feito'] else None,
            event['pathParameters']['id+'],
        ),
    )
    tarefa = cur.fetchone()

    conn.commit()
    cur.close()
    conn.close()

    if tarefa is None:
        return {
            'statusCode': 404,
        }
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
        },
        'body': json.dumps(dict(Tarefa(*tarefa))),
    }


def delete_tarefa(event, context):
    conn = pg_connect()
    cur = conn.cursor()

    cur.execute(
        SQL_DELETE, (
            event['pathParameters']['id+'],
        ),
    )
    tarefas = cur.rowcount

    conn.commit()
    cur.close()
    conn.close()

    return {
        'statusCode': 200 if tarefas > 0 else 404,
    }
