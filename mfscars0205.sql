--
-- PostgreSQL database dump
--

\restrict slgAsgMXZhFtoTun58GP7RDXf24tARThsJiJV6q68Obd9f1hHnfe2xhYXdqMU6G

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: atualizar_busca_veiculo(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.atualizar_busca_veiculo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

NEW.busca :=
to_tsvector(
'portuguese',
coalesce(NEW.marca,'') || ' ' ||
coalesce(NEW.modelo,'') || ' ' ||
coalesce(NEW.versao,'') || ' ' ||
coalesce(NEW.cor,'') || ' ' ||
coalesce(NEW.combustivel,'')
);

RETURN NEW;

END
$$;


ALTER FUNCTION public.atualizar_busca_veiculo() OWNER TO postgres;

--
-- Name: validar_usuario_loja_empresa(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validar_usuario_loja_empresa() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

  IF NOT EXISTS (
    SELECT 1
    FROM usuario u
    JOIN loja l ON l.id = NEW.loja_id
    WHERE u.id = NEW.usuario_id
    AND u.empresa_id = l.empresa_id
  ) THEN
    RAISE EXCEPTION 'Usuário e loja pertencem a empresas diferentes';
  END IF;

  RETURN NEW;

END;
$$;


ALTER FUNCTION public.validar_usuario_loja_empresa() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: assinatura; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assinatura (
    id integer NOT NULL,
    empresa_id integer,
    plano_id integer,
    data_inicio date,
    data_vencimento date,
    status character varying(30) DEFAULT 'ativa'::character varying
);


ALTER TABLE public.assinatura OWNER TO postgres;

--
-- Name: assinatura_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.assinatura_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.assinatura_id_seq OWNER TO postgres;

--
-- Name: assinatura_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.assinatura_id_seq OWNED BY public.assinatura.id;


--
-- Name: avaliacao_loja; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.avaliacao_loja (
    id integer NOT NULL,
    usuario_id integer,
    loja_id integer,
    nota integer,
    comentario text,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT avaliacao_loja_nota_check CHECK (((nota >= 1) AND (nota <= 5)))
);


ALTER TABLE public.avaliacao_loja OWNER TO postgres;

--
-- Name: avaliacao_loja_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.avaliacao_loja_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.avaliacao_loja_id_seq OWNER TO postgres;

--
-- Name: avaliacao_loja_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.avaliacao_loja_id_seq OWNED BY public.avaliacao_loja.id;


--
-- Name: empresa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.empresa (
    id integer NOT NULL,
    nome character varying(150) NOT NULL,
    email character varying(150),
    data_cadastro timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    senha text,
    slug character varying(120),
    telefone character varying(20),
    cidade character varying(100),
    estado character varying(2),
    cnpj character varying(18)
);


ALTER TABLE public.empresa OWNER TO postgres;

--
-- Name: empresa_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.empresa_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.empresa_id_seq OWNER TO postgres;

--
-- Name: empresa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.empresa_id_seq OWNED BY public.empresa.id;


--
-- Name: favorito; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.favorito (
    id integer NOT NULL,
    usuario_id integer,
    veiculo_id integer,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.favorito OWNER TO postgres;

--
-- Name: favorito_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.favorito_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.favorito_id_seq OWNER TO postgres;

--
-- Name: favorito_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.favorito_id_seq OWNED BY public.favorito.id;


--
-- Name: lead; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lead (
    id integer NOT NULL,
    veiculo_id integer,
    nome character varying(100),
    telefone character varying(30),
    mensagem text,
    origem character varying(50),
    data timestamp without time zone DEFAULT now(),
    empresa_id integer,
    loja_id integer NOT NULL,
    status character varying(20) DEFAULT 'novo'::character varying
);


ALTER TABLE public.lead OWNER TO postgres;

--
-- Name: lead_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lead_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lead_id_seq OWNER TO postgres;

--
-- Name: lead_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lead_id_seq OWNED BY public.lead.id;


--
-- Name: loja; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.loja (
    id integer NOT NULL,
    empresa_id integer NOT NULL,
    nome character varying(150) NOT NULL,
    slug character varying(150),
    cnpj character varying(18),
    telefone character varying(20),
    cep character varying(10),
    cidade character varying(100),
    estado character varying(2),
    endereco character varying(200),
    numero character varying(20),
    latitude numeric,
    longitude numeric,
    descricao text,
    horario_funcionamento text,
    instagram character varying(150),
    facebook character varying(150),
    site character varying(150),
    logo character varying(200),
    banner character varying(200),
    data_cadastro timestamp without time zone DEFAULT now(),
    plano_id integer,
    status character varying(20) DEFAULT 'ativa'::character varying,
    bairro character varying(100)
);


ALTER TABLE public.loja OWNER TO postgres;

--
-- Name: loja_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.loja_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.loja_id_seq OWNER TO postgres;

--
-- Name: loja_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.loja_id_seq OWNED BY public.loja.id;


--
-- Name: loja_plano; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.loja_plano (
    id integer NOT NULL,
    loja_id integer NOT NULL,
    plano_id integer NOT NULL,
    data_inicio timestamp without time zone DEFAULT now() NOT NULL,
    data_fim timestamp without time zone,
    status character varying(20) DEFAULT 'ativo'::character varying,
    valor_pago numeric(10,2),
    forma_pagamento character varying(50),
    data_pagamento timestamp without time zone,
    data_cancelamento timestamp without time zone,
    aviso_3_dias boolean DEFAULT false,
    aviso_vencido boolean DEFAULT false,
    criado_em timestamp without time zone DEFAULT now(),
    usados integer DEFAULT 0
);


ALTER TABLE public.loja_plano OWNER TO postgres;

--
-- Name: loja_plano_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.loja_plano_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.loja_plano_id_seq OWNER TO postgres;

--
-- Name: loja_plano_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.loja_plano_id_seq OWNED BY public.loja_plano.id;


--
-- Name: marca; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.marca (
    id integer NOT NULL,
    nome character varying(100)
);


ALTER TABLE public.marca OWNER TO postgres;

--
-- Name: marca_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.marca_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.marca_id_seq OWNER TO postgres;

--
-- Name: marca_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.marca_id_seq OWNED BY public.marca.id;


--
-- Name: menus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.menus (
    id integer NOT NULL,
    nome character varying(100) NOT NULL,
    rota character varying(200) NOT NULL,
    icone character varying(50),
    permissao character varying(100),
    ordem integer DEFAULT 0,
    ativo boolean DEFAULT true
);


ALTER TABLE public.menus OWNER TO postgres;

--
-- Name: menus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.menus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.menus_id_seq OWNER TO postgres;

--
-- Name: menus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.menus_id_seq OWNED BY public.menus.id;


--
-- Name: modelo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.modelo (
    id integer NOT NULL,
    nome character varying(150),
    marca_id integer
);


ALTER TABLE public.modelo OWNER TO postgres;

--
-- Name: modelo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.modelo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.modelo_id_seq OWNER TO postgres;

--
-- Name: modelo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.modelo_id_seq OWNED BY public.modelo.id;


--
-- Name: opcional; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.opcional (
    id integer NOT NULL,
    nome character varying(100)
);


ALTER TABLE public.opcional OWNER TO postgres;

--
-- Name: opcional_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.opcional_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.opcional_id_seq OWNER TO postgres;

--
-- Name: opcional_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.opcional_id_seq OWNED BY public.opcional.id;


--
-- Name: permissoes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permissoes (
    id integer NOT NULL,
    chave character varying(100) NOT NULL
);


ALTER TABLE public.permissoes OWNER TO postgres;

--
-- Name: permissoes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.permissoes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.permissoes_id_seq OWNER TO postgres;

--
-- Name: permissoes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.permissoes_id_seq OWNED BY public.permissoes.id;


--
-- Name: plano; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plano (
    id integer NOT NULL,
    nome character varying(100),
    preco numeric(10,2),
    limite_veiculos integer,
    ativo boolean DEFAULT true,
    destaque integer DEFAULT 0
);


ALTER TABLE public.plano OWNER TO postgres;

--
-- Name: plano_consumo_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plano_consumo_log (
    id integer NOT NULL,
    loja_id integer NOT NULL,
    veiculo_id integer,
    acao character varying(50) NOT NULL,
    criado_em timestamp without time zone DEFAULT now()
);


ALTER TABLE public.plano_consumo_log OWNER TO postgres;

--
-- Name: plano_consumo_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.plano_consumo_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.plano_consumo_log_id_seq OWNER TO postgres;

--
-- Name: plano_consumo_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.plano_consumo_log_id_seq OWNED BY public.plano_consumo_log.id;


--
-- Name: plano_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.plano_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.plano_id_seq OWNER TO postgres;

--
-- Name: plano_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.plano_id_seq OWNED BY public.plano.id;


--
-- Name: role_permissao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_permissao (
    role_id integer NOT NULL,
    permissao_id integer NOT NULL
);


ALTER TABLE public.role_permissao OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    nome character varying(50) NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario (
    id integer NOT NULL,
    empresa_id integer,
    nome character varying(150),
    email character varying(150),
    senha character varying(255),
    tipo character varying(50) DEFAULT 'admin'::character varying,
    ativo boolean DEFAULT true,
    data_cadastro timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    master boolean DEFAULT false
);


ALTER TABLE public.usuario OWNER TO postgres;

--
-- Name: usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuario_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuario_id_seq OWNER TO postgres;

--
-- Name: usuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuario_id_seq OWNED BY public.usuario.id;


--
-- Name: usuario_loja; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario_loja (
    id integer NOT NULL,
    usuario_id integer,
    loja_id integer,
    ativo boolean DEFAULT true,
    perfil character varying(50) DEFAULT 'vendedor'::character varying
);


ALTER TABLE public.usuario_loja OWNER TO postgres;

--
-- Name: usuario_loja_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuario_loja_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuario_loja_id_seq OWNER TO postgres;

--
-- Name: usuario_loja_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuario_loja_id_seq OWNED BY public.usuario_loja.id;


--
-- Name: usuario_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario_role (
    usuario_id integer NOT NULL,
    role_id integer NOT NULL,
    loja_id integer,
    id integer NOT NULL
);


ALTER TABLE public.usuario_role OWNER TO postgres;

--
-- Name: usuario_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuario_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuario_role_id_seq OWNER TO postgres;

--
-- Name: usuario_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuario_role_id_seq OWNED BY public.usuario_role.id;


--
-- Name: veiculo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.veiculo (
    id integer NOT NULL,
    empresa_id integer,
    marca character varying(100),
    modelo character varying(100),
    cor character varying(50),
    quilometragem integer,
    combustivel character varying(50),
    valor numeric(12,2),
    descricao text,
    status character varying(30) DEFAULT 'disponivel'::character varying,
    data_cadastro timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    video_url text,
    destaque boolean DEFAULT false,
    versao character varying(150),
    cambio character varying(50),
    carroceria character varying(50),
    final_placa character varying(1),
    aceita_troca boolean,
    licenciado boolean,
    codigo_interno character varying(50),
    placa character varying(10),
    renavam character varying(20),
    chassi character varying(30),
    ano_modelo character varying(20),
    tipo_compra character varying(20),
    preco_compra numeric(12,2),
    percentual_comissao numeric(5,2),
    valor_comissao numeric(12,2),
    data_entrada date,
    loja_id integer,
    slug character varying(200),
    busca tsvector
);


ALTER TABLE public.veiculo OWNER TO postgres;

--
-- Name: veiculo_documento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.veiculo_documento (
    id integer NOT NULL,
    veiculo_id integer NOT NULL,
    proprietario_id integer,
    tipo character varying(50) NOT NULL,
    arquivo text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    loja_id integer
);


ALTER TABLE public.veiculo_documento OWNER TO postgres;

--
-- Name: veiculo_documento_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.veiculo_documento_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.veiculo_documento_id_seq OWNER TO postgres;

--
-- Name: veiculo_documento_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.veiculo_documento_id_seq OWNED BY public.veiculo_documento.id;


--
-- Name: veiculo_foto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.veiculo_foto (
    id integer NOT NULL,
    veiculo_id integer,
    url character varying(255),
    principal boolean DEFAULT false,
    empresa_id integer,
    loja_id integer
);


ALTER TABLE public.veiculo_foto OWNER TO postgres;

--
-- Name: veiculo_foto_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.veiculo_foto_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.veiculo_foto_id_seq OWNER TO postgres;

--
-- Name: veiculo_foto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.veiculo_foto_id_seq OWNED BY public.veiculo_foto.id;


--
-- Name: veiculo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.veiculo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.veiculo_id_seq OWNER TO postgres;

--
-- Name: veiculo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.veiculo_id_seq OWNED BY public.veiculo.id;


--
-- Name: veiculo_midia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.veiculo_midia (
    id integer NOT NULL,
    veiculo_id integer NOT NULL,
    empresa_id integer NOT NULL,
    loja_id integer NOT NULL,
    tipo character varying(20) NOT NULL,
    url text NOT NULL,
    principal boolean DEFAULT false,
    ordem integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.veiculo_midia OWNER TO postgres;

--
-- Name: veiculo_midia_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.veiculo_midia_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.veiculo_midia_id_seq OWNER TO postgres;

--
-- Name: veiculo_midia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.veiculo_midia_id_seq OWNED BY public.veiculo_midia.id;


--
-- Name: veiculo_opcional; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.veiculo_opcional (
    id integer NOT NULL,
    veiculo_id integer,
    opcional_id integer,
    loja_id integer
);


ALTER TABLE public.veiculo_opcional OWNER TO postgres;

--
-- Name: veiculo_opcional_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.veiculo_opcional_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.veiculo_opcional_id_seq OWNER TO postgres;

--
-- Name: veiculo_opcional_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.veiculo_opcional_id_seq OWNED BY public.veiculo_opcional.id;


--
-- Name: veiculo_proprietario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.veiculo_proprietario (
    id integer NOT NULL,
    veiculo_id integer NOT NULL,
    nome character varying(150) NOT NULL,
    cpf_cnpj character varying(20),
    telefone character varying(20),
    email character varying(100),
    endereco text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    loja_id integer
);


ALTER TABLE public.veiculo_proprietario OWNER TO postgres;

--
-- Name: veiculo_proprietario_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.veiculo_proprietario_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.veiculo_proprietario_id_seq OWNER TO postgres;

--
-- Name: veiculo_proprietario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.veiculo_proprietario_id_seq OWNED BY public.veiculo_proprietario.id;


--
-- Name: veiculo_view; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.veiculo_view (
    id integer NOT NULL,
    veiculo_id integer NOT NULL,
    loja_id integer NOT NULL,
    ip character varying(50),
    user_agent text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.veiculo_view OWNER TO postgres;

--
-- Name: veiculo_view_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.veiculo_view_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.veiculo_view_id_seq OWNER TO postgres;

--
-- Name: veiculo_view_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.veiculo_view_id_seq OWNED BY public.veiculo_view.id;


--
-- Name: venda; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.venda (
    id integer NOT NULL,
    veiculo_id integer,
    empresa_id integer,
    data_venda date,
    nome_comprador text,
    cpf_comprador text,
    telefone_comprador text,
    condicao_pagamento text,
    parcelas integer,
    banco_financiamento text,
    valor_venda numeric(15,2),
    observacoes text,
    status character varying(20) DEFAULT 'concluida'::character varying,
    motivo_cancelamento text,
    loja_id integer NOT NULL,
    vendedor character varying(150),
    rg_comprador character varying(30),
    estado character varying(100),
    cidade character varying(100),
    bairro character varying(150),
    endereco character varying(200),
    numero character varying(20),
    complemento character varying(150),
    cep character varying(20),
    email character varying(150),
    profissao character varying(100),
    data_nasc date,
    renda numeric(15,2),
    valor_entrada numeric(14,2) DEFAULT 0,
    valor_parcela numeric(15,2) DEFAULT 0
);


ALTER TABLE public.venda OWNER TO postgres;

--
-- Name: venda_entrada; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.venda_entrada (
    id integer NOT NULL,
    venda_id integer NOT NULL,
    empresa_id integer NOT NULL,
    loja_id integer NOT NULL,
    marca character varying(100) NOT NULL,
    modelo character varying(100) NOT NULL,
    tipo character varying(50),
    ano_modelo character varying(12),
    renavam character varying(50),
    chassi character varying(100),
    placa character varying(20),
    cor character varying(50),
    numero_motor character varying(100),
    combustivel character varying(50),
    potencia character varying(50),
    km integer,
    valor_entrada numeric(15,2) NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.venda_entrada OWNER TO postgres;

--
-- Name: venda_entrada_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.venda_entrada_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.venda_entrada_id_seq OWNER TO postgres;

--
-- Name: venda_entrada_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.venda_entrada_id_seq OWNED BY public.venda_entrada.id;


--
-- Name: venda_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.venda_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.venda_id_seq OWNER TO postgres;

--
-- Name: venda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.venda_id_seq OWNED BY public.venda.id;


--
-- Name: versao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.versao (
    id integer NOT NULL,
    nome character varying(150),
    modelo_id integer,
    codigo_fipe character varying(20)
);


ALTER TABLE public.versao OWNER TO postgres;

--
-- Name: versao_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.versao_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.versao_id_seq OWNER TO postgres;

--
-- Name: versao_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.versao_id_seq OWNED BY public.versao.id;


--
-- Name: assinatura id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assinatura ALTER COLUMN id SET DEFAULT nextval('public.assinatura_id_seq'::regclass);


--
-- Name: avaliacao_loja id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avaliacao_loja ALTER COLUMN id SET DEFAULT nextval('public.avaliacao_loja_id_seq'::regclass);


--
-- Name: empresa id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empresa ALTER COLUMN id SET DEFAULT nextval('public.empresa_id_seq'::regclass);


--
-- Name: favorito id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorito ALTER COLUMN id SET DEFAULT nextval('public.favorito_id_seq'::regclass);


--
-- Name: lead id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead ALTER COLUMN id SET DEFAULT nextval('public.lead_id_seq'::regclass);


--
-- Name: loja id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loja ALTER COLUMN id SET DEFAULT nextval('public.loja_id_seq'::regclass);


--
-- Name: loja_plano id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loja_plano ALTER COLUMN id SET DEFAULT nextval('public.loja_plano_id_seq'::regclass);


--
-- Name: marca id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marca ALTER COLUMN id SET DEFAULT nextval('public.marca_id_seq'::regclass);


--
-- Name: menus id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menus ALTER COLUMN id SET DEFAULT nextval('public.menus_id_seq'::regclass);


--
-- Name: modelo id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modelo ALTER COLUMN id SET DEFAULT nextval('public.modelo_id_seq'::regclass);


--
-- Name: opcional id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opcional ALTER COLUMN id SET DEFAULT nextval('public.opcional_id_seq'::regclass);


--
-- Name: permissoes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissoes ALTER COLUMN id SET DEFAULT nextval('public.permissoes_id_seq'::regclass);


--
-- Name: plano id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plano ALTER COLUMN id SET DEFAULT nextval('public.plano_id_seq'::regclass);


--
-- Name: plano_consumo_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plano_consumo_log ALTER COLUMN id SET DEFAULT nextval('public.plano_consumo_log_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: usuario id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id SET DEFAULT nextval('public.usuario_id_seq'::regclass);


--
-- Name: usuario_loja id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_loja ALTER COLUMN id SET DEFAULT nextval('public.usuario_loja_id_seq'::regclass);


--
-- Name: usuario_role id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_role ALTER COLUMN id SET DEFAULT nextval('public.usuario_role_id_seq'::regclass);


--
-- Name: veiculo id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo ALTER COLUMN id SET DEFAULT nextval('public.veiculo_id_seq'::regclass);


--
-- Name: veiculo_documento id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_documento ALTER COLUMN id SET DEFAULT nextval('public.veiculo_documento_id_seq'::regclass);


--
-- Name: veiculo_foto id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_foto ALTER COLUMN id SET DEFAULT nextval('public.veiculo_foto_id_seq'::regclass);


--
-- Name: veiculo_midia id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_midia ALTER COLUMN id SET DEFAULT nextval('public.veiculo_midia_id_seq'::regclass);


--
-- Name: veiculo_opcional id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_opcional ALTER COLUMN id SET DEFAULT nextval('public.veiculo_opcional_id_seq'::regclass);


--
-- Name: veiculo_proprietario id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_proprietario ALTER COLUMN id SET DEFAULT nextval('public.veiculo_proprietario_id_seq'::regclass);


--
-- Name: veiculo_view id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_view ALTER COLUMN id SET DEFAULT nextval('public.veiculo_view_id_seq'::regclass);


--
-- Name: venda id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venda ALTER COLUMN id SET DEFAULT nextval('public.venda_id_seq'::regclass);


--
-- Name: venda_entrada id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venda_entrada ALTER COLUMN id SET DEFAULT nextval('public.venda_entrada_id_seq'::regclass);


--
-- Name: versao id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.versao ALTER COLUMN id SET DEFAULT nextval('public.versao_id_seq'::regclass);


--
-- Data for Name: assinatura; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assinatura (id, empresa_id, plano_id, data_inicio, data_vencimento, status) FROM stdin;
\.


--
-- Data for Name: avaliacao_loja; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.avaliacao_loja (id, usuario_id, loja_id, nota, comentario, created_at) FROM stdin;
\.


--
-- Data for Name: empresa; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.empresa (id, nome, email, data_cadastro, senha, slug, telefone, cidade, estado, cnpj) FROM stdin;
1	MFS Cars	admin@mfs.com	2026-05-02 20:57:10.091935	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: favorito; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.favorito (id, usuario_id, veiculo_id, created_at) FROM stdin;
\.


--
-- Data for Name: lead; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lead (id, veiculo_id, nome, telefone, mensagem, origem, data, empresa_id, loja_id, status) FROM stdin;
\.


--
-- Data for Name: loja; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.loja (id, empresa_id, nome, slug, cnpj, telefone, cep, cidade, estado, endereco, numero, latitude, longitude, descricao, horario_funcionamento, instagram, facebook, site, logo, banner, data_cadastro, plano_id, status, bairro) FROM stdin;
\.


--
-- Data for Name: loja_plano; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.loja_plano (id, loja_id, plano_id, data_inicio, data_fim, status, valor_pago, forma_pagamento, data_pagamento, data_cancelamento, aviso_3_dias, aviso_vencido, criado_em, usados) FROM stdin;
\.


--
-- Data for Name: marca; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.marca (id, nome) FROM stdin;
1	Toyota
2	Honda
3	Ford
4	Acura
5	Agrale
6	Alfa Romeo
7	AM Gen
8	Asia Motors
9	ASTON MARTIN
10	Audi
11	Baby
12	BMW
13	BRM
14	Bugre
15	BYD
16	CAB Motors
17	Cadillac
18	Caoa Chery
19	Caoa Chery/Chery
20	CBT Jipe
21	CHANA
22	CHANGAN
23	Chrysler
24	Citroën
25	Cross Lander
26	D2D Motors
27	Daewoo
28	Daihatsu
29	Denza
30	DFSK
31	Dodge
32	EFFA
33	Engesa
34	Envemo
35	Ferrari
36	FEVER
37	Fiat
38	Fibravan
40	FOTON
41	Fyber
42	GAC
43	GEELY
44	GM - Chevrolet
45	GREAT WALL
46	Gurgel
47	GWM
48	HAFEI
49	HITECH ELECTRIC
51	Hyundai
52	Isuzu
53	IVECO
54	JAC
55	Jaecoo
56	Jaguar
57	Jeep
58	Jetour
59	JINBEI
60	JPX
61	Kia Motors
62	Lada
63	LAMBORGHINI
64	Land Rover
65	Leapmotor
66	Lexus
67	LIFAN
68	LOBINI
69	Lotus
70	Mahindra
71	Maserati
72	Matra
73	Mazda
74	Mclaren
75	Mercedes-Benz
76	Mercury
77	MG
78	MINI
79	Mitsubishi
80	Miura
81	NETA
82	Nissan
83	Omoda
84	Peugeot
85	Plymouth
86	Pontiac
87	Porsche
88	RAM
89	RELY
90	Renault
91	Rolls-Royce
92	Rover
93	Saab
94	Saturn
95	Seat
96	SERES
97	SHINERAY
98	smart
99	SSANGYONG
100	Subaru
101	Suzuki
102	TAC
104	Troller
105	Volvo
106	VW - VolksWagen
107	Wake
108	Walk
109	ZEEKR
\.


--
-- Data for Name: menus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.menus (id, nome, rota, icone, permissao, ordem, ativo) FROM stdin;
1	Veículos	/app/veiculos	🚗	veiculo.visualizar	1	t
2	Novo Veículo	/app/veiculos/novo	➕	veiculo.criar	2	t
4	Leads	/app/leads	📊	lead.visualizar	4	t
5	Usuários	/app/usuarios	👤	usuario.visualizar	5	t
6	Permissões	/app/permissoes	🔐	permissao.visualizar	6	t
3	Lojas	/app/lojas	🏪	loja.visualizar	3	t
7	Vendas	/app/vendas	💰	venda.visualizar	7	t
\.


--
-- Data for Name: modelo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.modelo (id, nome, marca_id) FROM stdin;
1	Corolla	1
2	Hilux	1
3	Civic	2
4	HR-V	2
5	Fiesta	3
6	Avalon XLS 3.0	1
7	Band. Jipe 4x4 Sport 3.7 Diesel	1
8	Band.Jipe Cap.de Aço Chas. Curto Diesel	1
9	Band.Jipe Cap.de Aço Chas. Longo Diesel	1
10	Band.Jipe Capota de Lona Diesel	1
11	Band.Picape CD 2p Chassi Longo Diesel	1
12	Band.Picape CD 4p Chassi Longo Diesel	1
13	Band.Picape Chassi Curto Diesel	1
14	Band.Picape Chassi Longo Diesel	1
15	Camry LE	1
16	Camry SW LE 2.2 16V	1
17	Camry SW XLE 3.0 24V	1
18	Camry XLE  2.5 16V Aut. (Híbrido)	1
19	Camry XLE 3.0 24V 186cv	1
20	Camry XLE 3.5 24V Aut.	1
21	Celica GT 2.2 16V	1
22	Celica ST 1.8	1
23	Corolla Altis 1.8 16V Aut. (Híbrido)	1
24	Corolla Altis Prem. 1.8 Aut. (Híbrido)	1
25	Corolla ALTIS/A.Premiu. 2.0 Flex 16V Aut	1
26	Corolla Cross GR-S 2.0 16V Flex Aut.	1
27	Corolla Cross SE 1.8 16V Aut. (Híbrido)	1
28	Corolla Cross XR 2.0 16V Flex Aut.	1
29	Corolla Cross XRE 2.0 16V Flex Aut.	1
30	Corolla Cross XRV 1.8 16V Aut. (Híbrido)	1
31	Corolla Cross XRX 1.8 16V Aut. (Híbrido)	1
32	Corolla Cross XRX 2.0 16V Flex Aut.	1
33	Corolla DX/ SW DX 1.6 16V	1
34	Corolla Dynamic 2.0 Flex 16V Aut.	1
35	Corolla Fielder SW 1.8/1.8 XEi Flex Aut.	1
36	Corolla Fielder SW 1.8/1.8 XEi Flex Mec	1
37	Corolla Fielder SW S  1.8 16V 136cv Aut	1
38	Corolla Fielder SW S 1.8 16V 136cv Mec	1
39	Corolla Fielder SW SE-G 1.8 Flex 16V Aut	1
40	Corolla GLi 1.6 16V	1
41	Corolla GLi 1.8 16V Aut.	1
42	Corolla GLi 1.8 Flex 16V  Aut.	1
43	Corolla GLi 1.8 Flex 16V Mec.	1
44	Corolla GLi 2.0 16V Flex Aut.	1
45	Corolla GLi Upper 1.8 Flex 16V Aut.	1
46	Corolla GLi Upper Black P. 1.8 Flex Aut.	1
47	Corolla GR Circuit 1.6 Turbo 4x4 Mec	1
48	Corolla GR Core 1.6 Turbo 4x4 Mec	1
49	Corolla GR-Sport 2.0 Flex 16V Aut.	1
50	Corolla LE 1.8	1
51	Corolla LE 2.2 16V	1
52	Corolla S 1.8 16V 136cv Aut	1
53	Corolla S 1.8 16V 136cv Mec	1
54	Corolla SE-G 1.8 16V Mec.	1
55	Corolla SE-G 1.8/1.8 Flex 16V Aut.	1
56	Corolla SW LE 1.8/ XLi 1.6 16V	1
57	Corolla WG	1
58	Corolla XEi 1.8/1.8 Flex 16V Aut.	1
59	Corolla XEi 1.8/1.8 Flex 16V Mec.	1
60	Corolla XEi 2.0 Flex 16V Aut.	1
61	Corolla XLi 1.6 16V 110cv Aut.	1
62	Corolla XLi 1.6 16V 110cv Mec.	1
63	Corolla XLi 1.8/1.8 Flex 16V Aut.	1
64	Corolla XLi 1.8/1.8 Flex 16V Mec.	1
65	Corolla XRS 2.0 Flex 16V Aut.	1
66	Corona Aut.	1
67	Corona GLi Mec	1
68	Corona Mec.	1
69	ETIOS 1.3 Flex 16V 5p Mec.	1
70	ETIOS CROSS 1.5 Flex 16V 5p Aut.	1
71	ETIOS CROSS 1.5 Flex 16V 5p Mec.	1
72	ETIOS PLATINUM 1.5 Flex 16V 4p Aut.	1
73	ETIOS PLATINUM 1.5 Flex 16V 5p Mec.	1
74	ETIOS PLATINUM Sed. 1.5 Flex 16V 4p Aut.	1
75	ETIOS PLATINUM Sed. 1.5 Flex 16V 4p Mec.	1
76	ETIOS READY! 1.5 Flex 16V 5p Aut.	1
77	ETIOS X 1.3 Flex 16V 5p Aut.	1
78	ETIOS X 1.3 Flex 16V 5p Mec.	1
79	ETIOS X Plus 1.5 Flex 16V 5p Aut.	1
80	ETIOS X Plus 1.5 Flex 16V 5p Mec.	1
81	ETIOS X Plus Sedan 1.5 Flex 16V 4p Aut.	1
82	ETIOS X Plus Sedan 1.5 Flex 16V 4p Mec.	1
83	ETIOS X Sedan 1.5 Flex 16V 4p Aut.	1
84	ETIOS X Sedan 1.5 Flex 16V 4p Mec.	1
85	ETIOS XLS 1.5 Flex 16V 5p Mec.	1
86	ETIOS XLS 1.5 Flex 5p Aut.	1
87	ETIOS XLS Sedan 1.5 Flex 16V 4p Aut.	1
88	ETIOS XLS Sedan 1.5 Flex 16V 4p Mec.	1
89	ETIOS XS  1.3 Flex 16V 5p Mec.	1
90	ETIOS XS 1.5 Flex 16V 5p Aut.	1
91	ETIOS XS 1.5 Flex 16V 5p Mec.	1
92	ETIOS XS Sedan 1.5 Flex 16V 4p Aut.	1
93	ETIOS XS Sedan1.5 Flex 16V 4p Mec.	1
94	Hiace Furgão DX 2.8 TDI Aut.	1
95	Hiace Minibus DX 2.8 TDI 16L Aut.	1
96	Hilux 4x2 2.4 Diesel	1
97	Hilux 4x2 2.8 Diesel	1
98	Hilux CD 4x2 2.4 Diesel	1
99	Hilux CD 4x4 2.7 16V Flex Mec.	1
100	Hilux CD 4x4 2.8  Diesel Aut.	1
101	Hilux CD 4x4 2.8 Diesel Mec.	1
102	Hilux CD Conquest 4x4 2.8  Die.Aut	1
103	Hilux CD D4-D 4x2 2.5 16V 102cv TB Dies.	1
104	Hilux CD D4-D 4x4 2.5 16V 102cv TB Dies.	1
105	Hilux CD D4-D 4x4 3.0 TDI Dies. Mec.	1
106	Hilux CD DLX 4x2 2.8 Diesel	1
107	Hilux CD DLX 4x4 2.8 Diesel	1
108	Hilux CD DX 4x2 2.7 16V 142cv	1
109	Hilux CD DX 4x2 3.0 8V 90cv Diesel	1
110	Hilux CD DX 4x4 3.0 8V 90cv Diesel	1
111	Hilux CD GR-S 4x4 2.8 TDI Dies. Aut.	1
112	Hilux CD GR-S 4x4 4.0 V6 234cv Aut.	1
113	Hilux CD Limited 4x4 3.0 TDI Diesel Aut.	1
114	Hilux CD SR 4x2 2.7 16V/2.7 Flex Aut.	1
115	Hilux CD SR 4x2 2.7 16V/2.7 Flex Mec.	1
116	Hilux CD SR 4x4 2.8 TDI Diesel Aut.	1
117	Hilux CD SR 4x4 3.0 8V 116cv TB Diesel	1
118	Hilux CD SR 4x4 3.0 8V 90cv Diesel	1
119	Hilux CD SR CHALL. 4x4 2.8 TDI Dies Aut.	1
120	Hilux CD SR D4-D 4x2 3.0 163cv TDI Dies.	1
121	Hilux CD SR D4-D 4x4 3.0  TDI Dies.	1
122	Hilux CD SR D4-D 4x4 3.0 TDI Dies Aut.	1
123	Hilux CD SR5 4x4 2.8 Diesel	1
124	Hilux CD SRV 4x2 2.7 16V 142cv	1
125	Hilux CD SRV 4x2 2.7 Flex 16V Aut.	1
126	Hilux CD SRV 4x2 3.0 8V 90cv Diesel	1
127	Hilux CD SRV 4x4 2.7 Flex 16V Aut.	1
128	Hilux CD SRV 4x4 2.8 TDI Diesel Aut.	1
129	Hilux CD SRV 4x4 3.0 8V 116cv TB Diesel	1
130	Hilux CD SRV D4-D 4x2 3.0 163cv TDI Dies	1
131	Hilux CD SRV D4-D 4x4 3.0  TDI Dies	1
132	Hilux CD SRV D4-D 4x4 3.0 TDI Diesel Aut	1
133	Hilux CD SRX 4x4 2.8 TDI 16V Diesel Aut.	1
134	Hilux CD SRX Limited 4x4 2.8 TDI Die.Aut	1
135	Hilux CD SRX Plus 4x4 2.8 TDI Die. Aut.	1
136	Hilux Chassi 4x4 2.8 TDI Diesel Aut.	1
137	Hilux Chassi 4x4 2.8 TDI Diesel Mec.	1
138	Hilux Chassi D4-D 4x4 2.5 102cv TB Dies.	1
139	Hilux Chassi D4-D 4x4 3.0 TDI Dies. Mec.	1
140	Hilux CS 4x4 2.4 Diesel	1
141	Hilux CS 4x4 2.8 TDI Diesel Aut.	1
142	Hilux CS 4x4 2.8 TDI Diesel Mec.	1
143	Hilux CS D4-D 4x2 2.5 16V 102cv TB Dies.	1
144	Hilux CS D4-D 4x4 2.5 16V 102cv TB Dies.	1
145	Hilux CS D4-D 4x4 3.0 TDI Dies. Mec.	1
146	Hilux CS DLX 4x2 2.8 Diesel	1
147	Hilux CS DLX 4x4 2.8 Diesel	1
148	Hilux CS DX 4x2 2.7 16V 142cv	1
149	Hilux CS DX 4x2 3.0 8V 90cv Diesel	1
150	Hilux CS DX 4x4 3.0 8V 90cv Diesel	1
151	Hilux CS SR5 4x4 2.8 Diesel	1
152	Hilux CS SRV 4x2 2.7 16V 142cv	1
153	Hilux SW4 2.7 16V	1
154	Hilux SW4 3.4 V6	1
155	Hilux SW4 4x4 2.4 8V	1
156	Hilux SW4 4x4 2.8 Diesel	1
157	Hilux SW4 4x4 3.0 12V V6	1
158	Hilux SW4 4x4 3.0 24V V6	1
159	Hilux SW4 4x4 3.0 8V TB Diesel	1
160	Hilux SW4 Diamond 2.8 TB 4x4 Die. Aut.	1
161	Hilux SW4 GRS 2.8 TB 4x4 Diesel Aut.	1
162	Hilux SW4 SR 4x2 2.7/ 2.7 Flex 16V Aut.	1
163	Hilux SW4 SR 4x2 2.7/2.7 Flex 16V Mec.	1
164	Hilux SW4 SR D4-D 4x4 3.0 TDI Dies. Aut	1
165	Hilux SW4 SRV 4x2 2.7 Flex 16V Aut.	1
166	Hilux SW4 SRV 4x4 4.0 V6 24V Aut.	1
167	Hilux SW4 SRV D4-D 4x4 3.0 TDI Dies. Aut	1
168	Hilux SW4 SRV D4-D 4x4 3.0 TDI Dies. Mec	1
169	Hilux SW4 SRX 4x4 2.8 TDI 16V Dies. Aut.	1
170	Hilux SW4 SRX 4x4 4.0 V6 24V Aut.	1
171	Hilux SW4 SRX Diamo. 4x4 2.8 TB Die Aut.	1
172	Hilux SW4 SRX Plat. 4x4 2.8 TB Die. Aut.	1
173	Land Cruiser 4WD 4.5 24V	1
174	Land Cruiser Prado 3.0 4x4 TB Diesel Aut	1
175	Land Cruiser Prado 3.0 4x4 TB Diesel Mec	1
176	MR-2 Turbo 2.0	1
177	Paseo	1
178	Previa LE 2.4 16V	1
179	Previa LX 2.5	1
180	PRIUS 1.8 16V 5p Aut. (Híbrido)	1
181	RAV4 2.0 4x2 16V Aut.	1
182	RAV4 2.0 4x4 16V Aut.	1
183	RAV4 2.0 4x4 16V Mec.	1
184	RAV4 2.0 HIGH 4x2 16V Aut.	1
185	RAV4 2.0 TOP 4x2 16V Aut.	1
186	RAV4 2.4 4x2 16V 170cv Aut.	1
187	RAV4 2.4 4x4 16V 170cv Aut.	1
188	RAV4 2.5 4x4 16V Aut.	1
189	RAV4 2.5 S 4x4  Aut. (Híbrido)	1
190	RAV4 2.5 S Connect 4x4  Aut. (Híbrido)	1
191	RAV4 2.5 SX 4x4  Aut. (Híbrido)	1
192	RAV4 2.5 SX Connect 4x4  Aut. (Híbrido)	1
193	RAV4 2.5 XSE 4x4 Aut. (Híbrido)	1
194	Supra	1
195	T-100 3.4 V6	1
196	YARIS Cross XR 1.5 16V 5p Aut.	1
197	YARIS Cross XRE 1.5 16V 5p Aut.	1
198	YARIS Cross XRE 1.5 16V 5p Aut. (Híbrido)	1
199	YARIS Cross XRX 1.5 16V 5p Aut.	1
200	YARIS Cross XRX 1.5 16V 5p Aut. (Híbrido)	1
201	YARIS S 1.5 Flex 16V 5p Aut.	1
202	YARIS XL 1.3 Flex 16V 5p Aut.	1
203	YARIS XL 1.3 Flex 16V 5p Mec.	1
204	YARIS XL 1.5 Flex 16V 5p Aut.	1
205	YARIS XL Live 1.3 Flex 16V 5p Aut.	1
206	YARIS XL Live 1.3 Flex 16V 5p Mec.	1
207	YARIS XL Live Sedan 1.5 Flex 16V 4p Aut.	1
208	YARIS XL Live Sedan 1.5 Flex 16V 4p Mec.	1
209	YARIS XL Plus Con. 1.5 Flex 16V 5p Aut.	1
210	YARIS XL Plus Con. Sed. 1.5 Flex 16V Aut	1
211	YARIS XL Plus T. Sed. 1.5 Flex 16V Aut.	1
212	YARIS XL Plus Tech 1.3 Flex 16V Aut.	1
213	YARIS XL Sedan 1.5 Flex 16V 4p Aut.	1
214	YARIS XL Sedan 1.5 Flex 16V 4p Mec.	1
215	YARIS XLS 1.5 Flex 16V 5p Aut.	1
216	YARIS XLS Connect 1.5 Flex 16V 5p Aut.	1
217	YARIS XLS Connect Sed. 1.5 Flex 16V Aut.	1
218	YARIS XLS Sedan 1.5 Flex 16V 4p Aut.	1
219	YARIS XS 1.5 Flex 16V 5p Aut.	1
220	YARIS XS Connect 1.5 Flex 16V 5p Aut.	1
221	YARIS XS Connect Sedan 1.5 Flex 16V Aut.	1
222	YARIS XS Sedan 1.5 Flex 16V 4p Aut.	1
223	YARIS X-WAY 1.5 Flex 16V 5p Aut.	1
224	YARIS X-WAY Connect 1.5 Flex 16V 5p Aut.	1
225	Accord Coupe EX	2
226	Accord Sedan 2.0 TB 16V Aut. (Híbrido)	2
227	Accord Sedan EX 2.0 16V 156cv Aut.	2
228	Accord Sedan EX 2.4/2.3/ 2.2 16V	2
229	Accord Sedan EX 2.7/3.0 24V	2
230	Accord Sedan EX 3.5 V6 24V	2
231	Accord Sedan EXR	2
232	Accord Sedan LX  2.2/2.4 16V	2
233	Accord Sedan LX 2.0 16V 150/156cv Aut.	2
234	Accord Sedan Touring 2.0 TB 16V Aut.	2
235	Accord SW EX	2
236	Accord SW LX	2
237	CITY Hatchback EX 1.5 Flex 16V Aut.	2
238	CITY Hatchback EXL 1.5 Flex 16V Aut.	2
239	CITY Hatchback LX 1.5 Flex 16V Aut.	2
240	CITY Hatchback Touring 1.5 Flex 16V Aut	2
241	CITY Hatchback Touring Sport 1.5 16V Aut	2
242	CITY Sedan DX 1.5 Flex 16V Aut.	2
243	CITY Sedan DX 1.5 Flex 16V Mec.	2
244	CITY Sedan EX 1.5 Flex 16V 4p Aut.	2
245	CITY Sedan EX 1.5 Flex 16V 4p Mec.	2
246	CITY Sedan EXL 1.5 Flex  16V 4p Aut.	2
247	CITY Sedan EXL 1.5 Flex 16V 4p Mec.	2
248	CITY Sedan LX 1.5 Flex 16V 4p Aut.	2
249	CITY Sedan LX 1.5 Flex 16V 4p Mec.	2
250	CITY Sedan Personal 1.5 Flex 16V Aut.	2
251	CITY Sedan SPORT 1.5 FLEX 16V 4p Mec.	2
252	CITY Sedan Touring 1.5 Flex 16V 4p Aut.	2
253	Civic Coupe EX/ EXS 1.6 16V 2p	2
254	Civic Coupe Si 1.5 TB 16V 208cv Mec. 2p	2
255	Civic Coupe Si 2.4 16V 206cv Mec. 2p	2
256	Civic CRX/ Targa VTi	2
257	Civic Hatch DX	2
258	Civic Hatch LSi	2
259	Civic Hatch LX Aut.	2
260	Civic Hatch Si	2
261	Civic Hatch VTi	2
262	Civic Sed LX 1.8 Aut 4p	2
263	Civic Sed. LXL/ LXL SE 1.8 Flex 16V Aut.	2
264	Civic Sed. LXL/LXL SE 1.8 Flex 16V Mec.	2
265	Civic Sed.Touring 2.0 16V Aut. (Híbrido)	2
266	Civic Sedan EX 1.6 16V Aut. 4p (nacion.)	2
267	Civic Sedan EX 1.6 16V Mec. 4p (nacion.)	2
268	Civic Sedan EX 1.7 16V 130cv Aut. 4p	2
269	Civic Sedan EX 1.7 16v 130cv Mec. 4p	2
270	Civic Sedan EX 2.0 Flex 16V Aut.4p	2
271	Civic Sedan EX/ EXS 1.6 Mec. 4p	2
272	Civic Sedan EX/ EXS Aut. 4p/ Del-Sol 2p	2
273	Civic Sedan EXL 2.0 Flex 16V Aut.4p	2
274	Civic Sedan EXR 2.0 Flexone 16V Aut. 4p	2
275	Civic Sedan EXS 1.8/1.8 Flex 16V Aut. 4p	2
276	Civic Sedan LX 1.5/1.6	2
277	Civic Sedan LX 1.6 16V Aut. 4p	2
278	Civic Sedan LX 1.6 16V Mec. 4p	2
279	Civic Sedan LX 1.7 16V 115cv Mec. 4p	2
280	Civic Sedan LX 2.0 Flex 16V Aut. 4p	2
281	Civic Sedan LX/LXL 1.7 16V 115cv Aut. 4p	2
282	Civic Sedan LXB 1.6 16V 4p	2
283	Civic Sedan LXB 1.7 16V 115cv	2
284	Civic Sedan LXL 1.7 16V 130cv Aut 4p	2
285	Civic Sedan LXL 1.7 16V 130cv Mec 4p	2
286	Civic Sedan LXR 2.0 Flexone 16V Aut. 4p	2
287	Civic Sedan LXS 1.8/1.8 Flex 16V Aut. 4p	2
288	Civic Sedan LXS 1.8/1.8 Flex 16V Mec. 4p	2
289	Civic Sedan Si 2.0 16V  192cv 4p	2
290	Civic Sedan SPORT 2.0 Flex 16V Aut.4p	2
291	Civic Sedan SPORT 2.0 Flex 16V Mec.4p	2
292	Civic Sedan TOURING 1.5 Turbo 16V Aut.4p	2
293	Civic Type-R 2.0 Turbo 16V	2
294	CR-V 2.0 16V Aut.	2
295	CR-V 2.0 16V Mec.	2
296	CR-V 2.4 16V 156cv Aut. 4p	2
297	CR-V EXL 2.0 16V 4WD/2.0 Flexone Aut.	2
298	CR-V EXL 2.0 Flexone 16V 2WD Aut.	2
299	CR-V LX 2.0 16V 2WD Mec.	2
300	CR-V LX 2.0 16V 2WD/2.0 Flexone Aut.	2
301	CR-V Touring 1.5 16V 4WD 5p Aut.	2
302	CR-V Touring 2.0 16V AWD Aut.(Híbrido)	2
303	Fit CX 1.4 Flex 16V 5p Aut.	2
304	Fit CX 1.4 Flex 16V 5p Mec.	2
305	Fit DX 1.4 Flex 16V 5p Aut.	2
306	Fit DX 1.4 Flex 16V 5p Mec.	2
307	Fit DX 1.5 Flexone 16V 5p Aut.	2
308	Fit DX 1.5 Flexone 16V 5p Mec.	2
309	Fit EX/ S 1.5/ EX 1.5 Flex 16V 5p Mec.	2
310	Fit EX/S 1.5 Flex/Flexone 16V 5p Aut.	2
311	Fit EXL 1.5 Flex 16V 5p Mec	2
312	Fit EXL 1.5 Flex/Flexone 16V 5p Aut	2
313	Fit LX 1.4/ 1.4 Flex 8V/16V 5p Aut.	2
314	Fit LX 1.4/ 1.4 Flex 8V/16V 5p Mec.	2
315	Fit LX 1.5 Flexone 16V 5p Aut.	2
316	Fit LX 1.5 Flexone 16V 5p Mec.	2
317	Fit LXL 1.4/ 1.4 Flex 8V/16V 5p Aut.	2
318	Fit LXL 1.4/ 1.4 Flex 8V/16V 5p Mec.	2
319	Fit Personal 1.5 Flexone 16V 5p Aut.	2
320	Fit Twist 1.5 Flex 16V 5p Aut.	2
321	Fit Twist 1.5 Flex 16V 5p Mec.	2
322	HR-V Advance 1.5  Flex TB 16V 5p Aut.	2
323	HR-V EX 1.5 Flex Sensing 16V 5p Aut.	2
324	HR-V EX 1.8 Flexone 16V 5p Aut.	2
325	HR-V EXL 1.5 Flex Sensing 16V 5p Aut.	2
326	HR-V EXL 1.8 Flexone 16V 5p Aut.	2
327	HR-V LX 1.8 Flexone 16V 5p Aut.	2
328	HR-V LX 1.8 Flexone 16V 5p Mec.	2
329	HR-V Touring 1.5 Flex TB 16V 5p Aut.	2
330	HR-V Touring 1.8 Flexone 16V 5p Aut.	2
331	Odyssey EX Van Aut (6 lug.)	2
332	Odyssey Van LX Aut (6 lug.)	2
333	Passport EX	2
334	Passport LX	2
335	Passport PIck-Up 4x2	2
336	Prelude Coupê S 2.2	2
337	Prelude Si	2
338	WR-V EX 1.5 Flexone 16V 5p Aut.	2
339	WR-V EXL 1.5 Flexone 16V 5p Aut.	2
340	WR-V LX 1.5 Flexone 16V 5p Aut.	2
341	ZR-V Touring 2.0 16V 5p Aut.	2
342	Aerostar Mini-Van 3.8	3
343	Aspire 1.3	3
344	Belina GL 1.8 / 1.6	3
345	Belina L 1.8/ 1.6	3
346	Bronco Sport Badlands 2.0L TB 4WD Aut.	3
347	Bronco Sport Wildtrak 2.0 Tb 16V AWD Aut	3
348	Club Wagon V8	3
349	Club Wagon XLT 4.9 V6	3
350	Contour SE/ GL/ LX  2.0 16V	3
351	Contour SE/GL/ LX 2.5 24V	3
352	Corcel II GL/GT	3
353	Corcel II L	3
354	Courier 1.3i/Furgão	3
355	Courier 1.6 L/ 1.6 Flex	3
356	Courier CLX 1.4i 16V	3
357	Courier Si 1.4i 16V	3
358	Courier Sport 1.6 8v	3
359	Courier Van 1.6/ 1.6 Flex 8V (Carga)	3
360	Courier XL/XL-RS 1.6/ XL 1.6 Flex	3
361	Crown Victoria LX 4.6	3
362	Del Rey Belina Ghia	3
363	Del Rey Belina GL	3
364	Del Rey Belina GLX	3
365	Del Rey Belina L	3
366	Del Rey Ghia 1.8 / 1.6 2p e 4p	3
367	Del Rey GLX 1.6/1.8 / GL 1.6/1.8 2p e 4p	3
368	Del Rey L 1.8 / 1.6 2p e 4p	3
369	EcoSport  100 Anos 1.5 Flex 5p Aut.	3
370	EcoSport 4WD 2.0/ 2.0 Flex 16V 5p	3
371	EcoSport FREESTYLE 1.5 12V Flex 5p Aut.	3
372	EcoSport FREESTYLE 1.5 12V Flex 5p Mec.	3
373	EcoSport FREESTYLE 1.6 16V Flex 5p	3
374	EcoSport FREESTYLE 1.6 16V Flex 5p Aut.	3
375	EcoSport FREESTYLE 2.0 16V 4WD Flex 5p	3
376	EcoSport FREESTYLE 2.0 16V Flex 5p	3
377	EcoSport FREESTYLE 2.0 16V Flex 5p Aut.	3
378	EcoSport FREESTYLE PLUS 1.5 Flex 5p Aut.	3
379	EcoSport S 1.6 16V Flex 5p	3
380	EcoSport SE 1.5 12V Flex 5p Aut.	3
381	EcoSport SE 1.5 12V Flex 5p Mec.	3
382	EcoSport SE 1.6 16V Flex 5p Aut.	3
383	EcoSport SE 1.6 16V Flex 5p Mec.	3
384	EcoSport SE 2.0 16V Flex 5p Aut.	3
385	EcoSport SE Direct 1.5 Flex 5p Aut.	3
386	EcoSport SE Direct 1.6 16V Flex 5p Aut.	3
387	EcoSport STORM 2.0 4WD 16V Flex 5p Aut.	3
388	EcoSport TITANIUM 1.5 12V Flex 5p Aut.	3
389	EcoSport TITANIUM 1.6 16V Flex 5p	3
390	EcoSport TITANIUM 2.0 16V Flex 5p	3
391	EcoSport TITANIUM 2.0 16V Flex 5p Aut.	3
392	EcoSport XL 1.6/ 1.6 Flex 8V 5p	3
393	EcoSport XL Supercharger 1.0 8V 95cv 5p	3
394	EcoSport XLS 1.6/ 1.6 Flex 8V 5p	3
395	EcoSport XLS 2.0/2.0 Flex 16V 5p Aut.	3
396	EcoSport XLS FREESTYLE 1.6 Flex 8V 5p	3
397	EcoSport XLT 1.6/ 1.6 Flex 8V 5p	3
398	EcoSport XLT 2.0/ 2.0 Flex 16V 5p Aut.	3
399	EcoSport XLT 2.0/ 2.0 Flex 16V 5p Mec.	3
400	EcoSport XLT FREESTYLE 1.6 Flex 8V 5p	3
401	EcoSport XLT FREESTYLE 2.0 Flex 16V 5p	3
402	EDGE LIMITED 3.5 V6 24V AWD Aut.	3
403	EDGE LIMITED 3.5 V6 24V FWD Aut.	3
404	EDGE SEL 3.5 V6  24V FWD Aut.	3
405	EDGE SEL 3.5 V6 24V AWD Aut.	3
406	EDGE ST 2.7 V6 24V AWD Aut.	3
407	EDGE TITANIUM 3.5 V6 24V AWD Aut.	3
408	Escort  Racer 2.0i	3
409	Escort Ghia 1.8i / 1.8 / 1.6	3
410	Escort Ghia 2.0i / 2.0	3
411	Escort GL 1.6 MPI	3
412	Escort GL 1.6i / 1.6	3
413	Escort GL 1.8i / 1.8	3
414	Escort GL 1.8i 16V 3p	3
415	Escort GL 1.8i 16V 4p	3
416	Escort GLX 1.6i	3
417	Escort GLX 1.8i 16V 4p	3
418	Escort GLX 1.8i 8v	3
419	Escort Guarujá 1.8 4p	3
420	Escort Hobby 1.0	3
421	Escort Hobby 1.6	3
422	Escort L 1.8i / 1.8	3
423	Escort L/LX 1.6	3
424	Escort RS 1.8i 16V	3
425	Escort S.W GL 1.8i 16V	3
426	Escort S.W. GLX 1.8i 16V	3
427	Escort SW 1.9 16v	3
428	Escort SW GL 1.6 MPI	3
429	Escort XR3 1.8 / 1.6 Beneton/Form./Laser	3
430	Escort XR3 1.8 / 1.6 Conversível	3
431	Escort XR3 2.0i	3
432	Escort XR3 2.0i Conversível	3
433	E-TRANSIT Furgão Longo Teto Alto (Elétrico)	3
434	Expedition 5.4 V8	3
435	Explorer Limited 4.0 4x4 V6 213cv	3
436	Explorer Limited 5.0 4x4 V8	3
437	Explorer Sport 4.0 V6	3
438	Explorer XL 4x2 4.0 V6	3
439	Explorer XL 4x4 4.0 V6	3
440	Explorer XLT 4x2 4.0 V6	3
441	Explorer XLT 4x4 4.0 V6	3
442	F-100 2.3	3
443	F-100 Blazer 2.3	3
444	F-100 CD 2.3	3
445	F-100 Super 2.3	3
446	F-100 Super Série 2.3	3
447	F-1000 CD/Blazer 3.6	3
448	F-1000 CD/Blazer 3.9 Dies.	3
449	F-1000 Lightning/ Super 4.9i	3
450	F-1000 Regular Cab. 4.9i	3
451	F-1000 S. S. Diesel / S.S. Diesel Turbo	3
452	F-1000 SR XK  Deserter Diesel	3
453	F-1000 SR XK Deserter	3
454	F-1000 Super 3.6 / Super Série 3.6	3
455	F-1000 Super CE 4.9i / 3.6	3
456	F-1000 Super Diesel / Super Diesel Turbo	3
457	F-1000 Super Diesel CE 3.9	3
458	F-1000 Super Série CE 4.9/3.6	3
459	F-1000 Super Série CE Diesel 3.9	3
460	F-1000 Super/ S.Série 4x4 3.9 Diesel	3
461	F-1000 Tropical CD 4.9i	3
919	C3 Live 1.0 Flex 6V 5p Mec.	24
462	F-1000 Tropical CD HSD 2.5/4.3 Diesel TB	3
463	F-1000 Tropical SL/ Van 4.9i	3
464	F-1000 Tropical SL/ Van T.Diesel (todas)	3
465	F-1000 XL 2.5 HSD Diesel TB	3
466	F-1000 XL 4.9i	3
467	F-1000 XL 4.9i CE	3
468	F-1000 XL 4x4 Diesel Turbo	3
469	F-1000 XL Diesel Turbo	3
470	F-1000 XLT 2.5 HSD Diesel TB	3
471	F-1000 XLT 4x4 Diesel Turbo	3
472	F-1000 XLT CE 4.9i	3
473	F-1000 XLT Diesel Turbo	3
474	F-1000 XLT/XL Lighting 4.9i	3
475	F-150 Lariat 4x4 5.0 V8	3
476	F-150 Lariat Black 4x4 5.0 V8	3
477	F-150 Platinum 4x4 5.0 V8	3
478	F-150 Tremor 4x4 5.0 V8	3
479	F-150 XL Triton 4.3 V6	3
480	F-150 XLT Triton 4.3	3
481	F-150 XLT Triton 4.6 V8	3
482	F-150 XLT Triton 5.8	3
483	F-250 F-MILHA CD 3.9 TB Diesel	3
484	F-250 Tropica./Tropmine Exec. 3.9 Diesel	3
485	F-250 TropiCab CE 3.9 TB Diesel	3
486	F-250 Tropical 3.9 Diesel	3
487	F-250 Tropical 4.2 CE / CD Diesel TB	3
488	F-250 Tropical 4.2 V6	3
489	F-250 Tropical SL/ Van T.Diesel (todas)	3
490	F-250 Tropicampo CD 3.9 TB Diesel	3
491	F-250 Tropiclassic 3.9 TB Diesel	3
492	F-250 Tropivan Executive 3.9 TB Diesel	3
493	F-250 Tropivan/Tropi. Plus 3.9 TB Diesel	3
494	F-250 XL 3.9 4x2 Diesel	3
495	F-250 XL 3.9 4x4 TB Diesel	3
496	F-250 XL 3.9 CD TB Diesel	3
497	F-250 XL 4.2 180cv CD TB Diesel	3
498	F-250 XL 4.2 Turbo Diesel	3
499	F-250 XL 4.2 V6	3
500	F-250 XL Super Duty 3.9 Diesel	3
501	F-250 XL Super Duty 4.2 TB Diesel	3
502	F-250 XL Super Duty 4.2 V6	3
503	F-250 XLT 3.9 4x2 CD TB Diesel	3
504	F-250 XLT 3.9 4x2 Diesel TB	3
505	F-250 XLT 3.9 4x4 CD TB Diesel	3
506	F-250 XLT 3.9 4x4 TB Diesel	3
507	F-250 XLT 4.2 180cv CD TB Diesel	3
508	F-250 XLT 4.2 TB Diesel	3
509	F-250 XLT 4.2 V6	3
510	Fiesta 1.0 8V Flex/Class 1.0 8V Flex 5p	3
511	Fiesta 1.0i 3p e 5p	3
512	Fiesta 1.3  3p e 5p	3
513	Fiesta 1.5 16V Flex Mec. 5p	3
514	Fiesta 1.6 16V Flex Aut. 5p	3
515	Fiesta 1.6 16V Flex Mec. 5p	3
516	Fiesta 1.6 8V Flex/Class 1.6 8V Flex 5p	3
517	Fiesta Class 1.0 2p	3
518	Fiesta Class 1.0 4p	3
519	Fiesta Class 1.6 8V 98cv 5p	3
520	Fiesta CLX 1.3i 3p	3
521	Fiesta CLX 1.3i 5p	3
522	Fiesta CLX 1.4i 16V 3p e 5p	3
523	Fiesta GL 1.0 3p	3
524	Fiesta GL 1.0 5p	3
525	Fiesta GL Class 1.0i 5p	3
526	Fiesta GLX 1.6 8V 3p	3
527	Fiesta GLX 1.6 8V 5p	3
528	Fiesta Personnalité 1.0 8V 66cv 5p	3
529	Fiesta S 1.0 8V Flex 5p	3
530	Fiesta SE 1.0 8V Flex 5p	3
531	Fiesta SE 1.6 16V Flex 5p	3
532	Fiesta SE 1.6 8V Flex 5p	3
533	Fiesta SE Plus 1.6 16V Flex Aut. 5p	3
534	Fiesta SE Plus Direct 1.6 16V Flex Aut.	3
535	Fiesta SE Style 1.6 16V Flex Mec. 5p	3
536	Fiesta Sed. 1.6 8V Flex 4p	3
537	Fiesta Sed. Personnalité 1.0 8V 4p	3
538	Fiesta Sed. Supercharger 1.0 8V 4p	3
539	Fiesta Sed. TI./TI.Plus1.6 16V Flex Aut.	3
540	Fiesta Sedan 1.0 8V Flex 4p	3
541	Fiesta Sedan 1.6 16V Flex Aut.	3
542	Fiesta Sedan 1.6 16V Flex Mec.	3
543	Fiesta Sedan S 1.0 8V Flex 4p	3
544	Fiesta Sedan SE 1.0 8V Flex 4p	3
545	Fiesta Sedan SE 1.6 16V Flex 4p	3
546	Fiesta Sedan SE 1.6 8V Flex 4p	3
547	Fiesta Sedan SEL 1.6 16V Flex Aut.	3
548	Fiesta Sedan SEL 1.6 16V Flex Mec.	3
549	Fiesta Sedan Street 1.0 8v 4p	3
550	Fiesta Sedan Street 1.6 8v 4p	3
551	Fiesta Sedan TITANIUM 1.6 16V Flex Mec	3
552	Fiesta SEL 1.0 12V EcoBoost Aut. 5p	3
553	Fiesta SEL 1.6 16V Flex  Aut. 5p	3
554	Fiesta SEL 1.6 16V Flex Mec. 5p	3
555	Fiesta SEL Style 1.0 EcoBoost Aut . 5p	3
556	Fiesta SEL Style 1.6 16V Flex Mec. 5p	3
557	Fiesta Sport 1.0MPi 4p	3
558	Fiesta Sport 1.6 16V Flex Mec.	3
559	Fiesta Sport 1.6MPi 4p	3
560	Fiesta Street 1.0 8v 3p	3
561	Fiesta Street 1.6 8v 95cv 5p	3
562	Fiesta Street/ Action 1.0 8v 5p	3
563	Fiesta Supercharger 1.0 8V 95cv 5p	3
564	Fiesta TIT./TIT.Plus 1.6 16V Flex Aut.	3
565	Fiesta TIT.Plus 1.0 12V EcoBoost Aut. 5p	3
566	Fiesta TITANIUM 1.6 16V Flex Mec.	3
567	Fiesta TRAIL 1.0 8V Flex 5p	3
568	Fiesta TRAIL 1.6 8V Flex 5p	3
569	Focus 1.6 S/1.6 SE Flex 16v 5p Aut	3
570	Focus 1.6 S/SE/SE Plus Flex 8V/16V  5p	3
571	Focus 1.8 16V 5p	3
572	Focus 2.0 16V/ 2.0 16V Flex 5p	3
573	Focus 2.0 16V/SE/SE Plus Flex 5p Aut.	3
574	Focus Fastback SE/SE PLUS 2.0 Flex Aut.	3
575	Focus Fastback TIT./T.PLUS 2.0 Flex Aut.	3
576	Focus Ghia  2.0 16V/ 2.0 16V Flex 5p Aut	3
577	Focus Ghia Sed. 2.0 16V/ 2.0 16V Flex 4p	3
578	Focus Ghia Sed. 2.0 16V/2.0 16V Flex Aut	3
579	Focus Ghia/ XR 2.0 /Ghia 2.0 16V Flex 5p	3
580	Focus Sed. TI./TI.Plus 2.0 16V Flex  Aut	3
581	Focus Sedan 1.6 16V Flex 4p Aut.	3
582	Focus Sedan 1.6/1.6 Flex 8V/16V 4p Mec.	3
583	Focus Sedan 1.8 16V 115cv 4p	3
584	Focus Sedan 2.0 16V/2.0 16V Flex 4p	3
585	Focus Sedan 2.0 16V/2.0 16V Flex 4p Aut.	3
586	Focus TITA/TITA Plus 2.0  Flex 5p Aut.	3
587	Focus TITANIUM 2.0 16V Flex 5p Mec.	3
588	Furglaine 3.6	3
589	Furglaine 3.9 Diesel	3
590	Furglaine Chateaux/Exec. 3.9 Diesel	3
591	Fusion 2.5 16V 193cv Aut. (Híbrido)	3
592	Fusion 2.5L I-VCT Flex Aut.	3
593	Fusion SE 2.5 I-VCT Flex 16V Aut.	3
594	Fusion SEL 2.0 Ecobo. 16V 248cv Aut.	3
595	Fusion SEL 2.3 16V  162cv Aut.	3
596	Fusion SEL 2.5 16V 173cv Aut.	3
597	Fusion SEL 3.0 V6  24V 243cv Aut.	3
598	Fusion SEL 3.0 V6 AWD 24V 243cv Aut.	3
599	Fusion Titanium 2.0 145cv Aut. (Híbrido)	3
600	Fusion Titanium 2.0 GTDI Eco. Awd Aut.	3
601	Fusion Titanium 2.0 GTDI Eco. Fwd Aut.	3
602	Ibiza 3.9 Furgão Diesel	3
603	Ibiza Chat./Exec. 3.9 Diesel	3
604	Ka 1.0 8V/1.0 8V ST Flex 3p	3
605	Ka 1.0 FREESTYLE 12V Flex 5p Mec.	3
606	Ka 1.0 S TiVCT Flex 5p	3
607	Ka 1.0 SE/SE Plus TiVCT Flex 5p	3
608	Ka 1.0 SEL TiVCT Flex 5p	3
609	Ka 1.0 TECNO 12V Flex 5p	3
610	Ka 1.0 TECNO 8V Flex 3p	3
611	Ka 1.0i 3p	3
612	Ka 1.5 100 Anos Flex 5p Aut.	3
613	Ka 1.5 FreeStyle 12V Flex 5p Aut.	3
614	Ka 1.5 FreeStyle 12V Flex 5p Mec.	3
615	Ka 1.5 SE 12V Flex 5p Aut.	3
616	Ka 1.5 SE 12V Flex 5p Mec.	3
617	Ka 1.5 SE Plus 12V Flex 5p Aut.	3
618	Ka 1.5 SE Plus 12V Flex 5p Mec.	3
619	Ka 1.5 SE/SE PLUS 16V Flex 5p	3
620	Ka 1.5 Sedan SE 12V Flex 4p Aut.	3
621	Ka 1.5 Sedan SE 12V Flex 4p Mec.	3
622	Ka 1.5 Sedan SE Plus 12V Flex 4p Aut.	3
623	Ka 1.5 Sedan SE Plus 12V Flex 4p Mec.	3
624	Ka 1.5 Sedan SEL 12V Flex 4p Aut.	3
625	Ka 1.5 Sedan SEL 12V Flex 4p Mec.	3
626	Ka 1.5 Sedan TITANIUM 12V Flex 4p Aut.	3
627	Ka 1.5 TITANIUM 12V Flex 5p Aut.	3
628	Ka 1.6 8V Flex 3p	3
629	Ka 1.6 TECNO 8V Flex 3p	3
630	Ka Action 1.6 MPI 8V 95cv	3
631	Ka Black 1.0 MPI 8v 65cv	3
632	Ka Black 1.6 MPI 8v 95cv	3
633	Ka CLX 1.3i 3p	3
634	Ka GL 1.0i Zetec Rocam	3
635	Ka GL Image 1.0i/ 1.0i Zetec Rocam	3
636	Ka Image 1.0i	3
637	Ka MP3 1.0 MPI 8V 65cv	3
638	Ka MP3 1.6 MPI 8V 95cv	3
639	Ka SEL 1.5 16V Flex 5p	3
640	Ka Sport 1.6 8V Flex 3p	3
641	Ka Street 1.0i	3
642	Ka Tecno 1.0i 8v Zetec Rocam	3
643	Ka TRAIL 1.0 12V Flex Mec. 5p	3
644	Ka TRAIL 1.5 16V Flex Mec. 5p	3
645	Ka XR 1.6 MPI 8V	3
646	Ka+ Sedan 1.0 SE/SE PLUS TiVCT Flex 4p	3
647	Ka+ Sedan 1.0 SEL TiCVT Flex 4p	3
648	Ka+ Sedan 1.5 ADVANCED 16V Flex 4p	3
649	Ka+ Sedan 1.5 SE/SE PLUS 16V Flex 4p	3
650	Ka+ Sedan 1.5 SEL 16V Flex 4p	3
651	Maverick L. Black 2.0 EcoBoost AWD Aut.	3
652	Maverick Lariat FX4 2.0 EcoBoost Aut.	3
653	Maverick Lariat Hybrid 2.5 AWD Aut.	3
654	Maverick Lariat Hybrid 2.5 FWD Aut.	3
655	Maverick Tremor 2.0 EcoBoost 4WD Aut.	3
656	Mondeo CLX 1.8 4p e 5p	3
657	Mondeo CLX 1.8i SW	3
658	Mondeo CLX 2.0i 4p Aut	3
659	Mondeo CLX 2.0i 4p Mec	3
660	Mondeo CLX 2.0i SW Aut	3
661	Mondeo CLX 2.0i SW Mec	3
662	Mondeo Ghia 2.0 16V 143cv 4p Aut	3
663	Mondeo Ghia 2.0 16V 143cv 4p Mec	3
664	Mondeo Ghia 2.5 V6 Aut	3
665	Mondeo Ghia 2.5 V6 Mec	3
666	Mondeo GLX 2.0 16V 4p Aut	3
667	Mondeo GLX 2.0 4p e 5p	3
668	Mondeo GLX 2.0i SW Mec./ Aut.	3
669	Mustang 3.8 V6	3
670	Mustang 3.8 V6 Conv.	3
671	Mustang Black Shadow 5.0 V8	3
672	Mustang Cobra 5.7 V8	3
673	Mustang Dark Horse 5.0 V8 Aut.	3
674	Mustang GT Performance 5.0 V8 Aut.	3
675	Mustang GT Performance 5.0 V8 Mec.	3
676	Mustang GT Premium 5.0 V8	3
677	Mustang GT V8	3
678	Mustang GT V8 Conversível	3
679	Mustang MACH 1 5.0 V8	3
680	Mustang Mach-E GT Performance (Elétrico)	3
681	Pampa 4x4 Jeep GL / L 1.6	3
682	Pampa Ghia 1.6/1.8/DUO	3
683	Pampa GL 1.6/ 1.8	3
684	Pampa L 1.6	3
685	Pampa L 1.8i / 1.8	3
686	Pampa S 1.8	3
687	Probe 2.0/2.2	3
688	Probe GT 2.5 V6	3
689	Ranger 2.5 4x2 CD TB Diesel	3
690	Ranger 2.5 4x2 CE Diesel	3
691	Ranger 2.5 4x2 TB Diesel	3
692	Ranger 2.5 4x4 CD TB Diesel	3
693	Ranger 2.5 4x4 CE TB Diesel	3
694	Ranger 2.5 4x4 TB Diesel	3
695	Ranger 2.5i CD	3
696	Ranger 2.5i CE	3
697	Ranger 2.5i CS	3
698	Ranger Black 2.0 4x2 CD TB Diesel Aut.	3
699	Ranger Black 2.2 4x2 CD Diesel Aut.	3
700	Ranger FX4 3.2 20V 4x4 CD Diesel Aut.	3
701	Ranger Limited 2.3 150cv CD	3
702	Ranger Limited 2.5 16V 4x2 CD Flex	3
703	Ranger Limited 3.0 PSE 4x4 CD TB Diesel	3
704	Ranger Limited 3.0 V6 4x4 CD TB Die. Aut	3
705	Ranger Limited 3.2 4x4 CD Diesel Aut.	3
706	Ranger Limited+ 3.0 V6 4x4 CD TB Die Aut	3
707	Ranger Raptor 3.0 V6 Bi-Turbo 4WD AUT.	3
708	Ranger Splash CE	3
709	Ranger Splash CS	3
710	Ranger SPORT 2.5 Flex 16V 4x2 CS	3
711	Ranger SPORTRAC 2.2 16V 4x4 CD Dies Aut.	3
712	Ranger Storm 3.2 20V 4x4 CD Diesel Aut.	3
713	Ranger STX 4.0 CS/ CE	3
714	Ranger TROPICAB 2.5 16V 4X2 Flex	3
715	Ranger TROPICAB 3.2 20V 4X4 TB Diesel	3
716	Ranger TROPIVAN 2.5 16V 4X2 Flex	3
717	Ranger TROPIVAN 3.2 20V 4X4 TB Dies.Aut.	3
718	Ranger TROPIVAN 3.2 20V 4X4 TB Diesel	3
719	Ranger TROPIVAN XLT 2.3 16V 150cv	3
720	Ranger TROPIVAN XLT 3.0 PSE 4x2 TB Dies.	3
721	Ranger TROPIVAN XLT 3.0 PSE 4x4 TB Dies.	3
722	Ranger XL 2.0 4x4 CD Diesel Mec. 	3
723	Ranger XL 2.2 4x4 CD Diesel Mec.	3
724	Ranger XL 2.2 4x4 CS Diesel Mec.	3
725	Ranger XL 2.3 16v 137cv 4x2 CD Repower.	3
726	Ranger XL 2.3 16v 137cv 4x2 CE Repower.	3
727	Ranger XL 2.3 16v 137cv 4x2 CS Repower.	3
728	Ranger XL 2.3 CS	3
729	Ranger XL 2.8 8v 135cv 4x2 CD TB Diesel	3
730	Ranger XL 2.8 8v 135cv 4x2 CE TB Diesel	3
731	Ranger XL 2.8 8v 135cv 4x2 CS TB Diesel	3
732	Ranger XL 2.8 8v 135cv 4x4 CD TB Diesel	3
733	Ranger XL 2.8 8v 135cv 4x4 CE TB Diesel	3
734	Ranger XL 2.8 8v 135cv 4x4 CS TB Diesel	3
735	Ranger XL 3.0 PSE 163cv 4x2 CD TB Diesel	3
736	Ranger XL 3.0 PSE 163cv 4x2 CS TB Diesel	3
737	Ranger XL 3.0 PSE 163cv 4x4 CD TB Diesel	3
738	Ranger XL 3.0 PSE 163cv 4x4 CS TB Diesel	3
739	Ranger XL 4.0 12v V6 210cv 4x2 CS Repow.	3
740	Ranger XL 4.0 CS	3
741	Ranger XLS 2.0 4x2 CD Diesel Aut. 	3
742	Ranger XLS 2.0 4x4 CD Diesel Aut. 	3
743	Ranger XLS 2.2 4x2 CD Diesel Aut.	3
744	Ranger XLS 2.2 4x2 CD Diesel Mec.	3
745	Ranger XLS 2.2 4x4 CD Diesel Aut.	3
746	Ranger XLS 2.2 4x4 CD Diesel Mec.	3
747	Ranger XLS 2.3 16V 145cv/150cv 4x2 CD	3
748	Ranger XLS 2.3 16V 145cv/150cv 4x2 CS	3
749	Ranger XLS 2.5 16V 4x2 CD Flex	3
750	Ranger XLS 2.5 16V 4x2 CS Flex	3
751	Ranger XLS 2.8 8V 135cv 4x2 CD TB Diesel	3
752	Ranger XLS 2.8 8V 135cv 4x2 CS TB Diesel	3
753	Ranger XLS 2.8 8V 135cv 4x4 CS TB Diesel	3
754	Ranger XLS 2.8/2.8 Storm  4x4 CD TB Dies	3
755	Ranger XLS 3.0 PSE 163cv 4x2 CD TB Dies.	3
756	Ranger XLS 3.0 PSE 163cv 4x2 CS TB Dies.	3
757	Ranger XLS 3.0 PSE 163cv 4x4 CD TB Dies.	3
758	Ranger XLS 3.0 PSE Storm 4x4 CD TB Dies.	3
759	Ranger XLS 3.0 V6 4x4 CD Diesel Aut. 	3
760	Ranger XLS 3.2 20V 4x4 CD Diesel Aut.	3
761	Ranger XLS 3.2 20V 4x4 CD Diesel Mec.	3
762	Ranger XLS 3.2 20V 4x4 CS Diesel	3
763	Ranger XLS SPORT 2.3 16V 150cv CS	3
764	Ranger XLT 2.3 16V 150cv CD Repower.	3
765	Ranger XLT 2.3 CS	3
766	Ranger XLT 2.5 16V 4x2 CD Flex	3
767	Ranger XLT 2.5 4x2 CD Diesel	3
768	Ranger XLT 2.5 4x2 CE Diesel	3
769	Ranger XLT 2.5 4x2 CS Diesel	3
770	Ranger XLT 2.5 4x4 CD Diesel	3
771	Ranger XLT 2.5 4x4 CE TB Diesel	3
772	Ranger XLT 2.5 4x4 CS TB Diesel	3
773	Ranger XLT 2.8 8v 135cv 4x2 CD TB Diesel	3
774	Ranger XLT 2.8 8v 135cv 4x4 CD TB Diesel	3
775	Ranger XLT 2.8 8v 135cv 4x4 CE TB Diesel	3
776	Ranger XLT 3.0 PSE 163cv 4x2 CD TB Dies.	3
777	Ranger XLT 3.0 PSE 163cv 4x4 CD TB Dies.	3
778	Ranger XLT 3.0 V6 4x4 CD TB  Die. Aut.	3
779	Ranger XLT 3.2 20V 4x4 CD Diesel	3
780	Ranger XLT 3.2 20V 4x4 CD Diesel Aut.	3
781	Ranger XLT 4.0 12v V6 210cv 4x4 CD Repow	3
782	Ranger XLT 4.0 12v V6 210cv 4x4 CE Repow	3
783	Ranger XLT 4.0 4x2 CE	3
784	Ranger XLT 4.0 4x2 CS	3
785	Ranger XLT 4.0 4x4 CD	3
786	Ranger XLT 4.0 4x4 CE	3
787	Ranger XLT 4.0 4x4 CS	3
788	Ranger XLT Limit./L.Cent. 2.8 CD TB Dies	3
789	Royale Ghia 2.0/2.0i 2p e 4p	3
790	Royale GL 1.8/1.8i  2p e 4p	3
791	Royale GL 2.0/2.0i 2p e 4p	3
792	Taurus GL 3.0 V6	3
793	Taurus GL SW 3.0 V6 24V	3
794	Taurus L/LX 3.0 V6	3
795	Taurus LX SW 3.0 V6 24V	3
796	Taurus SHO 3.0 V6	3
797	TERRITORY SEL 1.5 GTDi EcoBoost Aut.	3
798	TERRITORY Titanium 1.5 GTDi EcoBo. Aut.	3
799	Thunderbird SC 3.8 V6	3
800	TRANSIT Chassi 2.2 TDCI Diesel	3
801	TRANSIT Chassi 2.4 TDCI Diesel	3
802	TRANSIT Chassi 350E 2.0 EcoBlue Diesel	3
803	TRANSIT Chassi 470E 2.0 EcoBlue Diesel	3
804	TRANSIT Furgão 2.0 Longo Turbo Die Aut.	3
805	TRANSIT Furgão 2.0 Longo Turbo Diesel 	3
806	TRANSIT Furgão 2.0 Medio Turbo Aut.	3
807	TRANSIT Furgão 2.0 Medio Turbo Diesel	3
808	TRANSIT Furgão 2.2 TDCI Curto Diesel	3
809	TRANSIT Furgão 2.2 TDCI Longa Diesel	3
810	TRANSIT Furgão 2.2 TDCI Longo Jumbo Dies	3
811	TRANSIT Furgão 3330 2.4 TDCI Curto Dies.	3
812	TRANSIT Furgão 3550 2.4 TDCI Longo Dies.	3
813	TRANSIT Minibus 15 Lug. 2.0 16V Die Aut.	3
814	TRANSIT Minibus 15 Lug. 2.0 16V Diesel	3
815	TRANSIT Minibus 18 Lug. 2.0 16V Die Aut.	3
816	TRANSIT Minibus 18 Lug. 2.0 16V Diesel	3
817	TRANSIT Minibus Vidrada 2.0 16V Die Aut.	3
818	TRANSIT Minibus Vidrada 2.0 16V Diesel	3
819	TRANSIT Van 3550 2.2 TDCI 14/16lug. Dies	3
820	TRANSIT Van 3550 2.4 TDCI 14lug. Diesel	3
821	Verona Ghia 2.0i 4p	3
822	Verona GL 1.8i / LX 1.8i 4p	3
823	Verona GLX 1.8 (Modelo antigo)	3
824	Verona GLX 1.8i / 1.8 4p	3
825	Verona GLX 2.0i / 2.0 4p	3
826	Verona LX 1.6 (Modelo antigo)	3
827	Verona LX 1.8 (Modelo antigo)	3
828	Verona S 2.0i 4p	3
829	Versailles Ghia 2.0i / 2.0 2p e 4p	3
830	Versailles GL 1.8i / 1.8 2p e 4p	3
831	Versailles GL 2.0i / 2.0 2p e 4p	3
832	Windstar GL	3
833	Windstar LX	3
834	Integra GS 1.8	4
835	Legend 3.2/3.5	4
836	NSX 3.0	4
837	MARRUÁ 2.8 12V 132cv TDI Diesel	5
838	MARRUÁ AM 100 2.8  CS TDI Diesel	5
839	MARRUÁ AM 100 2.8 CD TDI Diesel	5
840	MARRUÁ AM 150 2.8  CS TDI Diesel	5
841	MARRUÁ AM 150 2.8 CD TDI Diesel	5
842	MARRUÁ AM 200 2.8  CD TDI Diesel	5
843	MARRUÁ AM 200 2.8 CS TDI Diesel	5
844	MARRUÁ AM 200 Esc. 3.8 TDI Die.Aut. (E6)	5
845	MARRUÁ AM 200 Escolar 2.8 TDI Diesel	5
846	MARRUÁ AM 200 Escolar 3.8 TDI Die. (E6)	5
847	MARRUÁ AM 200 Microbus 2.8 TDI Diesel	5
848	MARRUÁ AM 250 3.8 CD TDI Die. Aut. (E6)	5
849	MARRUÁ AM 250 3.8 CD TDI Diesel (E6)	5
850	MARRUÁ AM 250 3.8 CS TDI Die. Aut. (E6)	5
851	MARRUÁ AM 250 3.8 CS TDI Diesel (E6)	5
852	MARRUÁ AM 50 2.8 140cv TDI Diesel	5
853	AIRCROSS 100 Anos 1.6 Flex 16V Aut.	24
854	AIRCROSS BUSINESS 1.6 Flex 16V 5p Mec.	24
855	AIRCROSS Exc. ATACA. 1.6 Flex 16V 5p Aut	24
856	AIRCROSS Exc. ATACA. 1.6 Flex 16V 5p Mec	24
857	AIRCROSS Exclusive 1.6 Flex 16V 5p Aut.	24
858	AIRCROSS Exclusive 1.6 Flex 16V 5p Mec.	24
859	AIRCROSS F. Pack 1.0 Flex TB 200 Aut.	24
860	AIRCROSS Feel 1.0 Flex Turbo 200 Aut.	24
861	AIRCROSS Feel 1.6 Flex 16V 5p Aut.	24
862	AIRCROSS Feel 1.6 Flex 16V 5p Mec.	24
863	AIRCROSS GL 1.6 Flex 16V 5p Mec.	24
864	AIRCROSS GLX 1.6 Flex 16V 5p Aut.	24
865	AIRCROSS GLX 1.6 Flex 16V 5p Mec.	24
866	AIRCROSS GLX ATACAMA 1.6 Flex 16V 5p Aut	24
867	AIRCROSS GLX ATACAMA 1.6 Flex 16V 5p Mec	24
868	AIRCROSS Live 1.5 Flex 8V 5p Mec.	24
869	AIRCROSS Live 1.6 Flex 16V 5p Aut.	24
870	AIRCROSS Live 1.6 Flex 16V 5p Mec.	24
871	AIRCROSS Live Bus. 1.6 Flex 5p Aut.	24
872	AIRCROSS SALOMON 1.5 Flex 8V 5p Mec.	24
873	AIRCROSS SALOMON 1.6 Flex 16V 5p Aut.	24
874	AIRCROSS SALOMON EXCLUSIVE 1.6 Flex Aut.	24
875	AIRCROSS SALOMON EXCLUSIVE 1.6 Flex Mec.	24
876	AIRCROSS SALOMON TENDANCE 1.6 Flex Aut.	24
877	AIRCROSS SALOMON TENDANCE 1.6 Flex Mec.	24
878	AIRCROSS Shine 1.0 Flex TB 200 Aut.	24
879	AIRCROSS Shine 1.6 Flex 16V 5p Aut.	24
880	AIRCROSS Start 1.5 Flex 8V 5p Mec.	24
881	AIRCROSS Start 1.6 Flex 16V 5p Mec.	24
882	AIRCROSS TENDANCE 1.6 Flex 16V 5p Aut.	24
883	AIRCROSS TENDANCE 1.6 Flex 16V 5p Mec.	24
884	AIRCROSS7 F. Pack 1.0 Flex TB 200 Aut	24
885	AIRCROSS7 Feel 1.0 Flex TB. 200 Aut.	24
886	AIRCROSS7 Shine 1.0 Flex TB 200 Aut.	24
887	AIRCROSS7 XTR 1.0 TB. 200 Aut.	24
888	AX GTi	24
889	BASALT Dark Edition 1.0 TB 200 5p Aut.	24
890	BASALT Feel 1.0 Flex 6V 5p Mec.	24
891	BASALT Feel 1.0 Flex TB 200 5p Aut.	24
892	BASALT First Edit.1.0 Flex TB 200 5p Aut	24
893	BASALT Shine 1.0 Flex TB 200 5p Aut.	24
894	Berlingo Furgão 1.6 16V Flex 5P	24
895	Berlingo MultSpace GLX 1.6 16V 110cv 4p	24
896	Berlingo MultSpace GLX 1.8i 3p	24
897	Berlingo MultSpace GLX 1.8i 4p	24
898	BX 1.6S 16V	24
899	BX GTi 1.9	24
900	C3 100 Anos 1.6 16V Flex Aut.	24
901	C3 Attra/Origine Pack 1.5 Flex 8V 5p Mec	24
902	C3 Attraction 1.6 Flex 16V 5p Aut.	24
903	C3 Attraction Pure Tech 1.2 Flex 12V Mec	24
904	C3 Excl. 1.6 VTi Flex Start 16V 5p Aut.	24
905	C3 Excl. 1.6 VTi Flex Start 16V 5p Mec.	24
906	C3 Excl./Excl.Solar./Sonora 1.6 Flex Aut	24
907	C3 Exclus./Excl.Solaris 1.6 Flex 16V Mec	24
908	C3 Exclusive 1.4 Flex 8V 5p	24
909	C3 Exclusive 1.5 Flex 8V 5p Mec.	24
910	C3 Exclusive Bus. 1.6 Flex 5p Aut.	24
911	C3 Feel 1.0 Flex 6V 5p Mec.	24
912	C3 Feel 1.6 Flex 16V 5p Mec.	24
913	C3 Feel Pack 1.6 Flex 16V 5p Aut.	24
914	C3 First Edition 1.0 Flex 6V 5p Mec.	24
915	C3 First Edition 1.6 Flex 16V 5p Aut.	24
916	C3 GLX 1.4/ GLX Sonora 1.4 Flex 8V 5p	24
917	C3 GLX 1.6 Flex 16V 5p  Aut.	24
918	C3 GLX 1.6/ 1.6 Flex 16V 5p	24
920	C3 Live Pack 1.0 Flex 6V 5p Mec.	24
921	C3 Live Pack 1.6 Flex 16V 5p Aut.	24
922	C3 Ocimar Versolato 1.6 16V 110cv 5p	24
923	C3 Origine 1.5 Flex 8V 5p Mec.	24
924	C3 Origine Pure Tech 1.2 Flex 12V Mec	24
925	C3 Picasso Excl. 1.6 Flex 16V 5p Aut.	24
926	C3 Picasso Exclusive 1.6 Flex 16V 5p Mec	24
927	C3 Picasso GL 1.5 Flex 8V Mec.	24
928	C3 Picasso GL 1.6 Flex 16V 5p Mec.	24
929	C3 Picasso GLX 1.5 Flex 8V 5p Mec.	24
930	C3 Picasso GLX 1.6 Flex 16V 5p Aut.	24
931	C3 Picasso GLX 1.6 Flex 16V 5p Mec.	24
932	C3 Picasso Origine 1.5 Flex 8V Mec.	24
933	C3 Picasso Tendance 1.5 Flex 8V 5p Mec.	24
934	C3 Picasso Tendance 1.6 Flex 16V 5p Aut.	24
935	C3 Start 1.2 Flex 12V 5p	24
936	C3 Style Ed. Pure Tech 1.2 Flex 12V Mec.	24
937	C3 Style Edition 1.6 Flex 16V Aut.	24
938	C3 Tendance 1.5 Flex 8V 5p Mec.	24
939	C3 Tendance 1.6 VTi Flex Start 16V Aut.	24
940	C3 Tendance Pure Tech 1.2 Flex 12V Mec.	24
941	C3 Urban Trail 1.6 Flex 16V 5p Aut.	24
942	C3 Urban Trail P.Tech 1.2 Flex 12V Mec.	24
943	C3 X-BOX ONE 1.6 VTi Flex 16V 5p Mec.	24
944	C3 XTR 1.0 8V 5p	24
945	C3 XTR 1.4 Flex 8V 5p	24
946	C3 XTR 1.6 Flex 16V 5p	24
947	C3 YOU! 1.0 Flex Turbo 200 Aut.	24
948	C4 CACTUS 100 Anos 1.6 TB 16V Flex Aut.	24
949	C4 CACTUS C-SERIES 1.6 16V Flex Aut.	24
950	C4 CACTUS FEEL 1.6 16V Flex Aut.	24
951	C4 CACTUS FEEL 1.6 16V Flex Mec.	24
952	C4 CACTUS FEEL Bus. 1.6 Flex Aut.	24
953	C4 CACTUS FEEL Pack 1.6 16V Flex Aut.	24
954	C4 CACTUS LIVE 1.6 16V Flex Aut.	24
955	C4 CACTUS LIVE 1.6 16V Flex Mec.	24
956	C4 CACTUS NOIR 1.6 Turbo Flex Aut.	24
957	C4 CACTUS Rip Curl 1.6 16V Flex Aut.	24
958	C4 CACTUS SHINE 1.6 16V Flex Aut.	24
959	C4 CACTUS SHINE 1.6 Turbo Flex Aut.	24
960	C4 CACTUS SHINE Pack 1.6 Turbo Flex Aut.	24
961	C4 CACTUS X-Series 1.6 16V Flex Aut.	24
962	C4 Competition 1.6 Flex 16V 5p Mec.	24
963	C4 Competition 2.0 Flex 16V 5p Aut.	24
964	C4 Excl./Excl. Solar. 2.0 Flex 16V Mec.	24
965	C4 Excl.2.0/2.0 Solaris Flex 16V 5p Aut.	24
966	C4 GLX 1.6 Flex 16V 5p Mec.	24
967	C4 GLX 2.0 Flex 16V 5p Aut.	24
968	C4 GLX 2.0 Flex 16V 5p Mec.	24
969	C4 LOUNGE 100 Anos 1.6 16V TB Flex Aut.	24
970	C4 LOUNGE Exclusive 1.6 Turbo 4p Aut.	24
971	C4 LOUNGE Exclusive 1.6 Turbo Flex Aut.	24
972	C4 LOUNGE Exclusive 2.0 Flex 4p Aut.	24
973	C4 LOUNGE Feel 1.6 Turbo Flex Aut.	24
974	C4 LOUNGE Live 1.6 Turbo Flex Aut.	24
975	C4 LOUNGE Live Bus. 1.6 Flex Aut.	24
976	C4 LOUNGE Orig.Business 1.6 TB Flex Aut.	24
977	C4 LOUNGE Origine 1.6 Turbo Flex  Aut.	24
978	C4 LOUNGE Origine 1.6 Turbo Flex Mec.	24
979	C4 LOUNGE Origine 2.0 Flex 4p Aut.	24
980	C4 LOUNGE Origine 2.0 Flex 4p Mec.	24
981	C4 LOUNGE S 1.6 Turbo Flex Aut.	24
982	C4 LOUNGE Shine 1.6 Turbo Flex Aut.	24
983	C4 LOUNGE Tendance 1.6 Turbo 4p Aut	24
984	C4 LOUNGE Tendance 1.6 Turbo Flex Aut.	24
985	C4 LOUNGE Tendance 2.0 Flex 4p Aut.	24
986	C4 LOUNGE Tendance 2.0 Flex 4p Mec.	24
987	C4 PAL.Excl/Excl(Tech.) 2.0/2.0 Flex Aut	24
988	C4 PALLAS Exclusive 2.0/2.0 Flex 16V Mec	24
989	C4 PALLAS GLX 2.0/ 2.0 Flex Aut.	24
990	C4 PALLAS GLX 2.0/2.0 Flex 16V Mec.	24
991	C4 Picasso Intensive 1.6 Turbo 16V Aut.	24
992	C4 Picasso Seduction 1.6 Turbo 16V Aut.	24
993	C4 Picasso/Pic. La Luna 2.0 16V  Aut.	24
994	C4 Rock You 1.6 Flex 16V 5p Mec.	24
995	C4 Tendance 1.6 Flex 16V 5p Mec.	24
996	C4 Tendance 2.0 Flex 16V 5p Aut.	24
997	C4 VTR 2.0 16V 143cv	24
998	C5 3.0 24V 210cv 4p Aut.	24
999	C5 Exclusive 2.0 16V 138cv 4p Mec.	24
1000	C5 Exclusive 2.0 16V 4p Aut.	24
1001	C5 Exclusive Break 2.0 16V 138cv 5p Mec.	24
1002	C5 Exclusive Break 2.0 16V Aut.	24
1003	C5 Tourer Exclusive 2.0 16V 5p Aut.	24
1004	C6 Exclusive 3.0 V6 24V 215cv Aut.	24
1005	C8 Exclusive 2.0 16V 138cv 5p Aut.	24
1006	DS3 1.6 Turbo 16V 3p Mec.	24
1007	DS3 Sport Chic 1.6 TB 16V 3p Mec.	24
1008	DS4 1.6 Chic Turbo 16V 5p Aut.	24
1009	DS4 1.6 So Chic Turbo 16V 5p Aut.	24
1010	DS4 1.6 Turbo 16V 5p Aut.	24
1011	DS5 1.6 Be Chic Turbo 16V 5p Aut.	24
1012	DS5 1.6 So Chic Turbo 16V 5p Aut.	24
1013	DS5 1.6 Turbo 16V 5p Aut.	24
1014	Ë-Jumpy Cargo 136cv (Elétrico)	24
1015	Evasion  GLX 2.0 16V	24
1016	Evasion VSX Turbo	24
1017	Grand C4 Picasso 2.0 16V 143cv Aut	24
1018	Grand C4 Picasso Intensive 1.6 TB Aut.	24
1019	Grand C4 Picasso Seduction 1.6 TB Aut.	24
1020	Jumper 2.0 Cargo Furgão 16V TB Diesel	24
1021	Jumper 2.0 FurgãoTurbo Diesel	24
1022	Jumper 2.0 Minibus 16L Turbo Diesel	24
1023	Jumper 2.3 15/16Lug. TB Diesel	24
1024	Jumper 2.3 Furgão TB Diesel	24
1025	Jumper 2.3 Vetrato Exec. 16Lug. TB Dies.	24
1026	Jumper 2.3 Vetrato TB Diesel	24
1027	Jumper 2.5 Diesel	24
1028	Jumper 2.8 16Lug.  Diesel	24
1029	Jumper 2.8 Furgão 35C Diesel	24
1030	Jumper 2.8 Furgão 35MH Diesel	24
1031	Jumper Cargo 2.2 Turbo Diesel	24
1032	Jumper Furgão 2.2 Turbo Diesel	24
1033	Jumper Minibus Executive 2.2 17L Dies. 	24
1034	Jumper Vitré 2.2 Turbo Diesel	24
1035	Jumpy 1.6  Furgão Pack Turbo Diesel	24
1036	Jumpy 1.6  Furgão Turbo Diesel	24
1037	Jumpy 1.6 Minibus Turbo Diesel	24
1038	Jumpy 2.2  Cargo Turbo	24
1039	Jumpy 2.2  Vitré Turbo	24
1040	Jumpy Cargo 1.5 Turbo Diesel	24
1041	Jumpy Vitré 1.5 Turbo Diesel	24
1042	Jumpy VITRÉ 1.6 Turbo Diesel	24
1043	Xantia 2.0  16V	24
1044	Xantia Activa 2.0	24
1045	Xantia Activa 2.0 TB	24
1046	Xantia Activa 3.0 V6 Mec	24
1047	Xantia Break 2.0 8V/GLX 2.0 16V Aut	24
1048	Xantia Break GLX 2.0 16V Mec.	24
1049	Xantia Exclusive 2.0 16V	24
1050	Xantia Exclusive 3.0 V6	24
1051	Xantia GLX 2.0 16V Aut.	24
1052	Xantia GLX 2.0 16V Mec.	24
1053	Xantia SX 1.8	24
1054	Xantia SX 2.0 8V/16V Mec./Aut.	24
1055	Xantia VSX 2.0	24
1056	Xantia VSX 2.0 16V	24
1057	XM Exclusive 12v	24
1058	XM Exclusive 24V	24
1059	XM Exclusive Break	24
1060	XM Sensation 2.0 TB	24
1061	Xsara Break Exclusive 1.6 16V 5p Aut.	24
1062	Xsara Break Exclusive 1.6 16V 5p Mec.	24
1063	Xsara Break Exclusive 1.8 16V	24
1064	Xsara Break Exclusive 2.0 16V	24
1065	Xsara Break GLX 1.6 16V 5p Aut.	24
1066	Xsara Break GLX 1.6 16V 5p Mec.	24
1067	Xsara Break GLX 1.8 16V	24
1068	Xsara Break GLX/ Paris 2.0 16V	24
1069	Xsara Exclusive 1.6 16V 5p Aut.	24
1070	Xsara Exclusive 1.6 16V 5p Mec.	24
1071	Xsara Exclusive 1.8 8V/16V 5p Aut.	24
1072	Xsara Exclusive 1.8 8V/16V 5p Mec.	24
1073	Xsara Exclusive 2.0 16V	24
1074	Xsara GLX 1.6 16V 3p	24
1075	Xsara GLX 1.6 16V 5p Aut.	24
1076	Xsara GLX 1.6 16V 5p Mec.	24
1077	Xsara GLX 1.8 16V 5p Mec.	24
1078	Xsara GLX 1.8 16V Cupê Mec.	24
1079	Xsara GLX 1.8 8V 5p Aut.	24
1080	Xsara GLX 1.8 8V Cupê Aut.	24
1081	Xsara GLX/ Paris 2.0 16V	24
1082	Xsara Picasso Exc./Etoile 2.0 16V Mec.	24
1083	Xsara Picasso Exclus. 1.6/ 1.6 Flex 16V	24
1084	Xsara Picasso Exclusive 2.0 16V Aut.	24
1085	Xsara Picasso GLX 1.6/ 1.6 Flex 16V	24
1086	Xsara Picasso GLX 2.0 16V  Aut.	24
1087	Xsara Picasso GLX/Brasil/Etoile 2.0 Mec.	24
1088	Xsara VTS 1.6 16V 3p	24
1089	Xsara VTS 1.8 16V	24
1090	Xsara VTS 2.0  16V Cupê Mec.	24
1091	ZX Cupê 16V	24
1092	ZX Dakar 2.0 16V	24
1093	ZX Furio	24
1094	ZX Paris 1.8	24
1095	ZX Volcane 3p e 5p	24
1096	147 C/ CL	37
1097	147 Furgão (todos)	37
1098	147 Pick-Up (todas)	37
1099	500 ABARTH MULTIAIR 1.4 TB 16V 3p	37
1100	500 Cabrio Dualogic Flex 1.4 8V	37
1101	500 Cabrio Flex 1.4 8V Mec.	37
1102	500 Cabrio/500 Coupe Gucci/Flex 1.4 Aut.	37
1103	500 Cult 1.4 Flex 8V EVO Dualogic	37
1104	500 Cult 1.4 Flex 8V EVO Mec.	37
1105	500 LOUNGE 1.4 16V 100cv  Mec.	37
1106	500 LOUNGE 1.4 16V 100cv Dualogic	37
1107	500 Lounge Air 1.4/ 1.4 Flex 16V Aut.	37
1108	500 SPORT 1.4 16V 100cv  Dualogic	37
1109	500 SPORT 1.4 16V 100cv Mec.	37
1110	500 Sport Air 1.4 16V/1.4 Flex 16V Aut.	37
1111	500 Sport Air 1.4 16V/1.4 Flex Mec.	37
1112	500e ICON (Elétrico)	37
1113	ARGO 1.0 6V Flex	37
1114	ARGO DRIVE 1.0 6V Flex	37
1115	ARGO DRIVE 1.3 8V Flex	37
1116	ARGO DRIVE 1.3 8V Flex Aut.	37
1117	ARGO DRIVE GSR 1.3 8V Flex	37
1118	ARGO DRIVE S-DESIGN 1.3 8V Flex	37
1119	ARGO DRIVE TRIBUTO 125 1.0 6V Flex	37
1120	ARGO ENDURANCE 1.3 8V Flex	37
1121	ARGO HGT 1.8 16V Flex Aut.	37
1122	ARGO HGT 1.8 16V Flex Mec.	37
1123	ARGO PRECISION 1.8 16V Flex Aut.	37
1124	ARGO PRECISION 1.8 16V Flex Mec.	37
1125	ARGO TREKKING 1.3 8V Flex	37
1126	ARGO TREKKING 1.3 8V Flex Aut.	37
1127	ARGO TREKKING 1.8 16V Flex Aut.	37
1128	Brava ELX  1.6 16V 4p	37
1129	Brava HGT 1.8 mpi 16V  4p	37
1130	Brava SX 1.6 16V 4p	37
1131	Bravo ABSOLUTE 1.8 Flex 16V 5p	37
1132	Bravo ABSOLUTE Dualogic 1.8 Flex 16V 5p	37
1133	Bravo BlackMotion 1.8 Dualogic Flex 5p	37
1134	Bravo BlackMotion 1.8 Flex 16v 5p	37
1135	Bravo ESSENCE 1.8 Flex 16V 5p	37
1136	Bravo ESSENCE Dualogic 1.8 Flex 16V 5p	37
1137	Bravo SPORTING 1.8 Dualogic Flex 16V 5p	37
1138	Bravo SPORTING 1.8 Flex 16V 5p	37
1139	Bravo SX 1.6	37
1140	Bravo T-JET 1.4 16V Turbo 5p	37
1141	Bravo WOLVERINE 1.8 Dualogic Flex 16V 5p	37
1142	Bravo WOLVERINE 1.8 Flex 16V 5p	37
1143	Cinquecento 0.7	37
1144	Coupe 16V	37
1145	CRONOS 1.0 6V Flex	37
1146	CRONOS 1.3 8V Flex	37
1147	CRONOS 1.8 16V Flex Aut. 	37
1148	CRONOS DRIVE 1.0 6V Flex	37
1149	CRONOS DRIVE 1.3 8V Flex	37
1150	CRONOS DRIVE 1.3 8V Flex Aut.	37
1151	CRONOS DRIVE 1.8 16V Flex Aut.	37
1152	CRONOS DRIVE GSR 1.3 8V Flex	37
1153	CRONOS HGT 1.8 16V Flex Aut.	37
1154	CRONOS PRECISION 1.3 8V Flex Aut.	37
1155	CRONOS PRECISION 1.8 16V Flex Aut.	37
1156	CRONOS PRECISION 1.8 16V Flex Mec.	37
1157	Doblo  1.4 mpi Fire Flex  8V 4p	37
1158	Doblo  Cargo 1.4 mpi Fire Flex 8V 3p	37
1159	Doblo Adv. XINGU 1.8 Flex 16V 5p	37
1160	Doblo Adv. XINGU LOCKER 1.8 Flex 16V 5p	37
1161	Doblo Adv.Ext./Adv.Ext.Loc. 1.8 16V Flex	37
1162	Doblo Adv/Adv TRYON/LOCKER 1.8 Flex	37
1163	Doblo Adventure/ Adv.ER 1.8 mpi 8V 103cv	37
1164	Doblo ATTRACTIVE 1.4 Fire Flex 8V 5p	37
1165	Doblo Cargo 1.3 Fire 16V 4/5p	37
1166	Doblo Cargo 1.6 16V 4/5p	37
1167	Doblo Cargo 1.8 mpi 8V 103cv	37
1168	Doblo Cargo 1.8 mpi Fire Flex 8V/16V 4p	37
1169	Doblo ELX 1.4 mpi Fire Flex 8V 4p	37
1170	Doblo ELX 1.6 16V 4/5p	37
1171	Doblo ELX 1.8 mpi 8V 103cv	37
1172	Doblo ELX 1.8 mpi 8V Flex	37
1173	Doblo ESSENCE 1.8 Flex 16V 5p	37
1174	Doblo EX 1.3 Fire 16V 80cv 4/5p	37
1175	Doblo HLX 1.8 mpi Flex 5p	37
1176	Ducato Cargo 2.2 Diesel (E6)	37
1177	Ducato Cargo 2.8 Curto/Longo TB Diesel	37
1178	Ducato Cargo Curto 2.3 16V Diesel	37
1179	Ducato Cargo Curto 2.3 ME Diesel	37
1180	Ducato Cargo Longo 2.3 ME Diesel	37
1181	Ducato Cargo Médio 2.3 16V Diesel	37
1182	Ducato Chassi 2.3 16V Diesel	37
1183	Ducato Combinato 2.3 ME Diesel	37
1184	Ducato Combinato 2.8 Diesel	37
1185	Ducato Combinato 2.8 Turbo Diesel	37
1186	Ducato Executivo 2.3 16V Diesel	37
1187	Ducato Furgão Maxi 2.8 Diesel	37
1188	Ducato Maxi. Curta 2.3 T.Alto ME Diesel	37
1189	Ducato Maxi. Long. 2.3 T.Alto ME Diesel	37
1190	Ducato MaxiCargo 2.2 Diesel (E6)	37
1191	Ducato MaxiCargo 2.3 16V Diesel	37
1192	Ducato MaxiCargo/Furgão Maxi 2.8 TB Dies	37
1193	Ducato MaxiMulti 2.3 16V Diesel	37
1194	Ducato Minibus 2.2 Comf.19L Diesel (E6)	37
1195	Ducato Minibus 2.2 Comfort18L (E6)	37
1196	Ducato Minibus 2.2 Exec. 17L Diesel (E6)	37
1197	Ducato Minibus 2.2 Luxo 16L (E6)	37
1198	Ducato Minibus 2.3 16V Diesel	37
1199	Ducato Minibus 2.3 ME Diesel	37
1200	Ducato Minibus 2.3 T.Alto ME Diesel	37
1201	Ducato Minibus 2.8 Diesel	37
1202	Ducato Minibus 2.8 Turbo Diesel	37
1203	Ducato Minibus Comfort 2.3 16v Diesel	37
1204	Ducato Mult/ Vetrato 2.8 T.Alto TB Dies.	37
1205	Ducato Mult/ Vetrato 2.8 T.Baixo TB Dies	37
1206	Ducato Multi 2.2 Diesel (E6)	37
1207	Ducato Multi 2.3 16V Diesel	37
1208	Ducato Multi Long. 2.3 T.Alto ME Diesel	37
1209	Ducato Van 2.5  Diesel	37
1210	Ducato Vip Bus 2.3 16V Diesel	37
1211	Ducato-10 Furgão 2.5 Diesel	37
1212	Ducato-15 2.8 Furgão TB Diesel	37
1213	Ducato-15 Furgão 2.8 Diesel	37
1214	Ducato-8 Furgão 2.5 Diesel	37
1215	Duna 1.6ie	37
1216	Elba 1.6i.e/Top/CSL/ 1.6i.e/1.5 2p e 4p	37
1217	Elba CS 1.6 / 1.5 /1.3	37
1218	Elba S 1.6/ 1.5ie / 1.5 / 1.3	37
1219	Elba Weekend 1.5 i.e. 2p e 4p	37
1220	E-Scudo (Elétrico)	37
1221	Fastback 1.0 200 Turbo Flex Aut	37
1222	Fastback ABARTH Turbo Flex 1.3 Aut.	37
1223	Fastback Audace 1.0 200 T. Flex Aut	37
1224	Fastback Audace 200 TB Aut (Hibrído)	37
1225	Fastback Impetus 1.0 200 T. Flex Aut	37
1226	Fastback Impetus 200 T. Aut (Hibrído)	37
1227	Fastback Limited Ed.1.3 270 T.Flex Aut.	37
1228	Fastback Tributo 125 1.0 Turb. Flex Aut 	37
1229	Fiorino Endurance 1.3 Flex 8V 2p	37
1230	Fiorino Endurance EVO 1.4 Flex 8V 2p	37
1231	Fiorino Furg.1.5/1.3/1.3 Fire/1.3 F.Flex	37
1232	Fiorino Furgão 1.0	37
1233	Fiorino Furgão 1.5 mpi / i.e.	37
1234	Fiorino Furgão Celeb. EVO 1.4 Flex 8V 2p	37
1235	Fiorino Furgão EVO 1.4 Flex 8V 2p	37
1236	Fiorino Furgão Work. HARD 1.4 Flex 8V 2p	37
1237	Fiorino Pick-Up 1.0	37
1238	Fiorino Pick-Up 1.5 i.e./1.3/1.5/HD	37
1239	Fiorino Pick-Up LX (todas)	37
1240	Fiorino Pick-Up Trekking 1.5 mpi / i.e.	37
1241	Fiorino Pick-Up Working 1.5 mpi / i.e.	37
1242	Fiorino Working 1.4 Flex 8V 2p	37
1243	FREEMONT EMOT./PRECISION 2.4 16V 5p Aut.	37
1244	Grand Siena 1.0 EVO Flex 8V 4p	37
1245	Grand Siena 1.4 EVO Flex 8V 4p	37
1246	Grand Siena ATTRAC. 1.4 EVO F.Flex 8V	37
1247	Grand Siena ATTRACTIVE 1.0 Flex 8V 4p	37
1248	Grand Siena ESSEN. ITALIA Dual. 1.6 Flex	37
1249	Grand Siena ESSEN.SUBLIME 1.6 Flex	37
1250	Grand Siena ESSEN.SUBLIME Dual. 1.6 Flex	37
1251	Grand Siena ESSENCE 1.6 Flex 16V	37
1252	Grand Siena ESSENCE Dual. 1.6 Flex 16V	37
1253	Grand Siena ESSENCE ITALIA 1.6 Flex 16V	37
1254	Grand Siena TETRAFUEL 1.4 Evo F. Flex 8V	37
1255	Idea A.Ext./A..Ext.Loc.Dual. 1.8 Flex 5p	37
1256	Idea Adv./ Adv.LOCK.Dualogic 1.8 Flex 5p	37
1257	Idea Adv.Ext./Adv.Ext. Loc. 1.8 Flex 5p	37
1258	Idea Advent./ Adv.LOCKER 1.8 mpi Flex 5p	37
1259	Idea ATTRACTIVE 1.4 Fire Flex 8V 5p	37
1260	Idea ELX 1.4 mpi Fire Flex 8V 5p	37
1261	Idea ELX 1.8 mpi Flex 8V 5p	37
1262	Idea ESSENCE 1.6 Flex 16V 5p	37
1263	Idea ESSENCE Dualogic 1.6 Flex 16V 5p	37
1264	Idea ESSENCE SUBLIME 1.6 Flex 16V 5p	37
1265	Idea ESSENCE SUBLIME Dual.1.6 Flex16V 5p	37
1266	Idea HLX 1.8 mpi Flex 8V 5p	37
1267	Idea SPORTING 1.8 Flex 16V 5p	37
1268	Idea SPORTING Dualogic 1.8 Flex 16V 5p	37
1269	LINEA 1.9/ HLX 1.9/ 1.8 Flex 16V 4p	37
1270	LINEA 1.9/ HLX 1.9/1.8 Flex  Dualogic 4p	37
1271	LINEA ABSOLUTE 1.9/1.8 Flex Dualogic 4p	37
1272	LINEA ESSEN.SUBLIME 1.8 Flex 16V 4p	37
1273	LINEA ESSEN.SUBLIME Dual.1.8 Flex 16V 4p	37
1274	LINEA ESSENCE 1.8 Flex 16V 4p	37
1275	LINEA ESSENCE Dualogic 1.8 Flex 16V 4p	37
1276	LINEA LX 1.9/ 1.8 Flex 16V 4p	37
1277	LINEA LX 1.9/ 1.8 Flex 16V Dualogic 4p	37
1278	LINEA T-JET 1.4 16V Turbo 4p	37
1279	Marea City	37
1280	Marea ELX 1.8 mpi 16V 132cv 4p	37
1281	Marea ELX 2.0 20V 4p	37
1282	Marea ELX 2.4 mpi 20V 4p	37
1283	Marea HLX 2.0 20V 4p	37
1284	Marea HLX 2.4 mpi 20V 4p Aut.	37
1285	Marea HLX 2.4 mpi 20V 4p Mec.	37
1286	Marea SX 1.6 mpi 16V 106cv 4p	37
1287	Marea SX 1.8 16V 4p	37
1288	Marea SX 2.0 20V 4p	37
1289	Marea Turbo 2.0 20V 4p	37
1290	Marea Weekend City 4p	37
1291	Marea Weekend ELX 1.8 mpi 16V 132cv 4p	37
1292	Marea Weekend ELX 2.0 20V 4p	37
1293	Marea Weekend ELX 2.4 mpi 20V 4p	37
1294	Marea Weekend HLX 2.0 20V 4p	37
1295	Marea Weekend HLX 2.4 mpi 20V 4p Aut.	37
1296	Marea Weekend HLX 2.4 mpi 20V 4p Mec.	37
1297	Marea Weekend SX 1.6 mpi 16V 106cv 4p	37
1298	Marea Weekend SX 1.8 16V 4p	37
1299	Marea Weekend SX 2.0 20V 4p	37
1300	Marea Weekend Turbo 2.0 20V 4p	37
1301	MOBI DRIVE 1.0 Flex 6V 5p	37
1302	MOBI DRIVE GSR 1.0 Flex 6V 5p	37
1303	MOBI EASY 1.0 Fire Flex 5p.	37
1304	MOBI EASY COMFORT 1.0 Flex 5p.	37
1305	MOBI EASY on 1.0 Fire Flex 5p.	37
1306	MOBI LIKE 1.0 Fire Flex 5p.	37
1307	MOBI LIKE ON 1.0 Fire Flex 5p.	37
1308	MOBI TREKKING 1.0 Flex 5p.	37
1309	MOBI WAY 1.0 Fire Flex 5p.	37
1310	MOBI WAY on 1.0 Fire Flex 5p.	37
1311	Oggi	37
1312	Palio 1.0 Cel. ECON./ITALIA F.Flex 8V 4p	37
1313	Palio 1.0 Celebr. ECONOMY F.Flex 8V 2p	37
1314	Palio 1.0 ECONOMY Fire Flex 8V 2p	37
1315	Palio 1.0 ECONOMY Fire Flex 8V 4p	37
1316	Palio 1.0/ Trofeo 1.0 Fire/ Fire Flex 2p	37
1317	Palio 1.0/ Trofeo 1.0 Fire/ Fire Flex 4p	37
1318	Palio 1.5 mpi 8V 2p	37
1319	Palio 1.5 mpi 8V 4p	37
1320	Palio 1.6 mpi 16V 2p	37
1321	Palio 1.6 mpi 16V 4p	37
1322	Palio 1.8R mpi Flex 8V 2p	37
1323	Palio 1.8R mpi Flex 8V 4p	37
1324	Palio ATTRA. Best Seller 1.0 EVO Flex 5p	37
1325	Palio ATTRA. Best Seller 1.4 EVO Flex 5p	37
1326	Palio ATTRA./ITÁLIA 1.4 EVO F.Flex 8V 5p	37
1327	Palio ATTRACTIVE 1.0 EVO Fire Flex 8v 5p	37
1328	Palio Celebration 1.0 Fire Flex 8V 2p	37
1329	Palio Celebration 1.0 Fire Flex 8V 4p	37
1330	Palio City 1.0 4p	37
1331	Palio City 1.5/1.6 4p	37
1332	Palio CityMatic 1.0 mpi	37
1333	Palio ED 1.0 mpi 2p e 4p	37
1334	Palio EDX 1.0 mpi 2p	37
1335	Palio EDX 1.0 mpi 4p	37
1336	Palio EL 1.5 mpi 2p e 4p	37
1337	Palio EL 1.6 spi 2p e 4p	37
1338	Palio ELX 1.0 Fire/30 Anos F. Flex 8V 4p	37
1339	Palio ELX 1.0 mpi Fire 16v 4p (25 anos)	37
1340	Palio ELX 1.0/ 1.0 Fire Flex 8V 2p	37
1341	Palio ELX 1.3 mpi  Fire 16V 4p	37
1342	Palio ELX 1.3 mpi Flex 8V 4p	37
1343	Palio ELX 1.4 Fire/30 Anos F. Flex 8V 4p	37
1344	Palio ELX 1.5 4p	37
1345	Palio ELX 1.6 4p	37
1346	Palio ELX 1.6 mpi 16v 4p	37
1347	Palio ELX 1.8/ 1.8 mpi Flex 8V 4p	37
1348	Palio ELX Dualogic 1.8 mpi Flex 8V 4p	37
1349	Palio ELX/ 500 1.0 4p	37
1350	Palio ESSENCE 1.6 Flex 16V 5p	37
1351	Palio ESSENCE Dualogic 1.6 Flex 16V 5p	37
1352	Palio EX 1.0 mpi 2p	37
1353	Palio EX 1.0 mpi 4p	37
1354	Palio EX 1.0 mpi Fire 8v 4p	37
1355	Palio EX 1.0 mpi Fire/ Fire Flex 8v 2p	37
1356	Palio EX 1.3 mpi Fire 8V 67cv 2p	37
1357	Palio EX 1.3 mpi Fire 8V 67cv 4p	37
1358	Palio EX 1.8 mpi 8V 103cv 4p	37
1359	Palio EX Century 1.0 mpi Fire 16v 2p	37
1360	Palio EX Century 1.0 mpi Fire 16v 4p	37
1361	Palio HLX 1.8 mpi 8V 103cv 4p	37
1362	Palio HLX 1.8 mpi Flex 8V 4p	37
1363	Palio Rua 1.0 Fire Flex 8V 5p	37
1364	Palio SPORT.INTERLAGOS 1.6 Flex 16V	37
1365	Palio SPORT.INTERLAGOS Dual.1.6 Flex 16V	37
1366	Palio SPORTING 1.6 Flex 16V 5p	37
1367	Palio SPORTING B.Edit. 1.6 Flex 16V 5p	37
1368	Palio SPORTING Dual. B.Edit. 1.6 Flex 5p	37
1369	Palio SPORTING Dualogic 1.6 Flex 16V 5p	37
1370	Palio Stile 1.6 mpi 16v 4p	37
1371	Palio W.Adv. LOC. ITAL.Dual.1.8 Flex 16V	37
1372	Palio W.ADV. LOCK. ITALIA 1.8 Flex 16V	37
1373	Palio Way 1.0 Fire Flex 8V 5p	37
1374	Palio Way Celebration 1.0 F. Flex 8V 5p	37
1375	Palio Week. Adv. Dualogic 1.8 Flex	37
1376	Palio Week. Adv. ITALIA 1.8 Flex 16V	37
1377	Palio Week. Adv/Adv TRYON 1.8 mpi Flex	37
1378	Palio Week. ATTRACTIVE 1.4 Fire Flex 8V	37
1379	Palio Week.Adv. ITAL. Dual. 1.8 Flex 16V	37
1380	Palio Week.Adv.LOCK.Dualogic 1.8 Flex	37
1381	Palio Weekend 1.0 6-marchas	37
1382	Palio Weekend 1.5 mpi 4p	37
1383	Palio Weekend 1.6 mpi 16V 4p	37
1384	Palio Weekend Adv. Ext. 1.8 Dual. Flex	37
1385	Palio Weekend Adv. Ext. 1.8 Flex	37
1386	Palio Weekend Adv. Loc.Ext.1.8 Dual.Flex	37
1387	Palio Weekend Adv. LOCKER Ext. 1.8 Flex	37
1388	Palio Weekend Adventure 1.6 8V/16V	37
1389	Palio Weekend Adventure 1.8 8V 103cv 4p	37
1390	Palio Weekend Adventure LOCKER 1.8 Flex	37
1391	Palio Weekend City 1.5/ 1.6 4p	37
1392	Palio Weekend ELX 1.0 mpi Fire 16V	37
1393	Palio Weekend ELX 1.3 mpi  Fire 16V	37
1394	Palio Weekend ELX 1.3 mpi Flex 8V 4p	37
1395	Palio Weekend ELX 1.4 mpi Fire Flex 8V	37
1396	Palio Weekend ELX 1.5 mpi 4p	37
1397	Palio Weekend ELX 1.6 mpi	37
1398	Palio Weekend EX 1.3 mpi Fire 8V 67cv 4p	37
1399	Palio Weekend EX 1.5 mpi	37
1400	Palio Weekend EX 1.8 mpi 8V 103cv 4p	37
1401	Palio Weekend HLX 1.8 mpi Flex 4p	37
1402	Palio Weekend Sport 1.6 mpi 16V 4p	37
1403	Palio Weekend Stile 1.6 mpi 16V 4p	37
1404	Palio Weekend Stile 1.8 mpi 8V 103cv 4p	37
1405	Palio Weekend Trekking 1.4 Fire Flex 8V	37
1406	Palio Weekend Trekking 1.6 Flex 16V 5p	37
1407	Palio Weekend Trekking 1.8 mpi Flex 8V	37
1408	Palio Young 1.0 mpi 8v 2p	37
1409	Palio Young 1.0 mpi 8v 4p	37
1410	Palio Young 1.0 mpi Fire 8V 2p	37
1411	Palio Young 1.0 mpi Fire 8V 4p	37
1412	Panorama C/CL	37
1413	Premio CS 1.5 i.e. 2p/ SL 1.6/1.5/1.3 4p	37
1414	Premio CS 1.6/ 1.5/ 1.3 2p	37
1415	Premio CSL 1.6 i.e./ 1.5 4p	37
1416	Premio CSL 1.6/ 1.5	37
1417	Premio S 1.5 i.e./ 1.5 / 1.3	37
1418	PULSE 1.0 Turbo 200  Flex Aut.	37
1419	PULSE ABARTH 1.3 Turbo 16V Flex Aut.	37
1420	PULSE AUDACE 1.0 Turbo 200 Flex Aut.	37
1421	PULSE AUDACE Turbo 200  Aut. (Hibrído)	37
1422	PULSE DRIVE 1.0 Turbo 200 Flex Aut.	37
1423	PULSE DRIVE 1.3 8V Flex Aut.	37
1424	PULSE DRIVE 1.3 8V Flex Mec. 	37
1425	PULSE IMPETUS 1.0 TURBO 200 Flex Aut.	37
1426	PULSE IMPETUS T. 200 Aut. (Hibrído)	37
1427	PULSE TRIBUTO 125 1.0 TB. 200 Flex Aut.	37
1428	Punto  ELX 1.4 Fire Flex 8V 5p	37
1429	Punto 1.4 Fire Flex 8V 5p	37
1430	Punto ATTRACTIVE 1.4 Fire Flex 8V 5p	37
1431	Punto ATTRACTIVE ITALIA 1.4 F.Flex 8V 5p	37
1432	Punto BLACKMOTION 1.8 Flex 16V 5p.	37
1433	Punto BLACKMOTION Dual. 1.8 Flex 16v 5p	37
1434	Punto Cabrio	37
1435	Punto EL/ELX	37
1436	Punto ESSENCE 1.6 Flex 16V 5p	37
1437	Punto ESSENCE 1.8 Flex 16V 5p	37
1438	Punto ESSENCE Dualogic 1.6 Flex 16V 5p	37
1439	Punto ESSENCE Dualogic 1.8 Flex 16V 5p	37
1440	Punto ESSENCE SP 1.6 Flex 16V 5p	37
1441	Punto ESSENCE SP Dualogic 1.6 Flex 16V	37
1442	Punto HLX 1.8 Flex 8V 5p	37
1443	Punto S	37
1444	Punto Sporting 1.8 Flex 8V/16V 5p	37
1445	Punto Sporting Dualogic 1.8 Flex 16V 5p	37
1446	Punto SX	37
1447	Punto T-JET 1.4 16V Turbo 5p	37
1448	Scudo Cargo 1.5 16V Turbo Diesel	37
1449	Scudo Cargo 2.2 16V Turbo Diesel	37
1450	Scudo Multi 1.5 16 V Turbo Diesel	37
1451	Scudo Multi 2.2 16 V Turbo Diesel	37
1452	Siena 1.0 mpi/ 500 1.0 mpi	37
1453	Siena 1.0/ EX 1.0 mpi Fire/ Fire Flex 8v	37
1454	Siena 1.5 mpi 8V 4p	37
1455	Siena ATTRACTIVE 1.0 Fire Flex 8V 4p	37
1456	Siena ATTRACTIVE 1.4 Fire Flex 8V 4p	37
1457	Siena Celebration 1.0 Fire Flex 8V 4p	37
1458	Siena City 4p	37
1459	Siena EL 1.0 mpi Fire Flex 8V 4p	37
1460	Siena EL 1.4 mpi Fire Flex 8V 4p	37
1461	Siena EL 1.6 mpi 16V	37
1462	Siena EL 1.6 spi	37
1463	Siena EL Celeb. 1.0 mpi Fire Flex 8V 4p	37
1464	Siena EL Celeb. 1.4 mpi Fire Flex 8V 4p	37
1465	Siena ELX 1.0 mpi Fire 16v 4p (25 anos)	37
1466	Siena ELX 1.0 mpi Fire/Fire Flex 8V 4p	37
1467	Siena ELX 1.3 mpi Fire 16V 4p	37
1468	Siena ELX 1.3 mpi Flex 8V 4p	37
1469	Siena ELX 1.4 mpi Fire Flex 8V 4p	37
1470	Siena ELX 1.5 mpi 4p	37
1471	Siena ELX 1.6 mpi 8V/16V 4p	37
1472	Siena ELX 1.8 mpi 8V 103cv 4p	37
1473	Siena ESSENCE 1.6 Flex 16V 4p	37
1474	Siena ESSENCE Dualogic 1.6 Flex 16V 4p	37
1475	Siena EX 1.0 mpi Fire 16v 4p	37
1476	Siena EX 1.3 mpi Fire 8V 67cv 4p	37
1477	Siena EX 1.8 mpi 8V 103cv 4p	37
1478	Siena HL 1.6 mpi 16V	37
1479	Siena HLX 1.8 mpi Flex 8V 4p	37
1480	Siena HLX Dualogic 1.8 mpi Flex 8V 4p	37
1481	Siena Sporting 1.6 Flex 16V 4p	37
1482	Siena Sporting Dualogic 1.6 Flex 16V 4p	37
1483	Siena Stile/Sport MTV 1.6 mpi 16V	37
1484	Siena TETRAFUEL 1.4 mpi Fire Flex 8v 4p	37
1485	Stilo 1.8 ATTRACTIVE Flex 8V 5p	37
1486	Stilo 1.8 MS Lim.Edit./ MS Season 16V	37
1487	Stilo 1.8 SP Flex 8V 5p	37
1488	Stilo 1.8 Sporting Flex 8V 5P	37
1489	Stilo 1.8/ 1.8 Connect 8V 103cv 5p	37
1490	Stilo 1.8/ 1.8 Connect Flex 8V 5p	37
1491	Stilo 1.8/ 1.8 SP/ Connect 16V 122cv 5p	37
1492	Stilo 2.4 Abarth 20V 167cv 5p	37
1493	Stilo Dualogic 1.8 ATTRACTIVE Flex 8V 5p	37
1494	Stilo Dualogic 1.8 BlackMotion Flex 8V	37
1495	Stilo Dualogic 1.8 Flex 8V 5p	37
1496	Stilo Dualogic 1.8 SP Flex 8V 5p	37
1497	Stilo Dualogic 1.8 Sporting Flex 8V 5p	37
1498	Strada 1.3 mpi Fire 8V 67cv CE	37
1499	Strada 1.3 mpi Fire 8V 67cv CS	37
1500	Strada 1.4 mpi Fire Flex 8V CE	37
1501	Strada 1.4 mpi Fire Flex 8V CS	37
1502	Strada Adv. Ext. 1.8 LOCKER Dual.Flex CE	37
1503	Strada Adv. Ext./ Ext.1.8 LOCKER Flex CE	37
1504	Strada Adv. Extreme 1.8 Dual. Flex CE	37
1505	Strada Adv. M. March. 1.8 Flex 16V CD	37
1506	Strada Adv. M. March.1.8 Dual. Flex CD	37
1507	Strada Adv.1.8 16V  LOCKER Dual. Flex CE	37
1508	Strada Adv.1.8 16V Dualogic Flex CD	37
1509	Strada Adv.1.8 16V Dualogic Flex CE	37
1510	Strada Adv.1.8 16V LOCKER Dualo. Flex CD	37
1511	Strada Adv.Ext. 1.8 LOCKER Dual. Flex CD	37
1512	Strada Adv.Ext./ Ext. 1.8 LOCKER Flex CD	37
1513	Strada Adv/Adv TRYON 1.8 mpi Flex 8V CE	37
1514	Strada Adventure 1.6 mpi 16V CE	37
1515	Strada Adventure 1.8 mpi 8V 103cv CE	37
1516	Strada Adventure 1.8/ 1.8 LOCKER Flex CE	37
1517	Strada Adventure Ext. 1.8  Dual. Flex CD	37
1518	Strada Adventure1.8/ 1.8 LOCKER Flex CD	37
1519	Strada Celeb. 1.4 mpi Fire Flex 8V CE	37
1520	Strada Celeb. 1.4 mpi Fire Flex 8V CS	37
1521	Strada Endurance 1.3 Flex 8V CS Plus	37
1522	Strada Endurance 1.4 Flex 8V CD	37
1523	Strada Endurance 1.4 Flex 8V CS Plus	37
1524	Strada Freedom 1.3 Flex 8V  CS Plus	37
1525	Strada Freedom 1.3 Flex 8V CD	37
1526	Strada Freedom 1.4 Flex 8V CD	37
1527	Strada Freedom 1.4 Flex 8V CS	37
1528	Strada LX 1.6 16V CE	37
1529	Strada LX 1.6 mpi 16V	37
1530	Strada Opening Edition 1.3 Flex 8V CD	37
1531	Strada Ranch 1.0 Flex Turbo CD Aut.	37
1532	Strada Ranch 1.3 Flex 8V CD Aut.	37
1533	Strada Sporting 1.8 Flex 16V CE	37
1534	Strada Trek. M. March. 1.6 Flex 16V CE	37
1535	Strada Trekking 1.4 mpi Fire Flex 8V CE	37
1536	Strada Trekking 1.4 mpi Fire Flex 8V CS	37
1537	Strada Trekking 1.6 16V Flex CD	37
1538	Strada Trekking 1.6 16V Flex CE	37
1539	Strada Trekking 1.6 16V Flex CS	37
1540	Strada Trekking 1.6 16V LOCKER Flex  CD	37
1541	Strada Trekking 1.6 mpi	37
1542	Strada Trekking 1.8 mpi Flex 8V CE	37
1543	Strada Trekking 1.8 mpi Flex 8V CS	37
1544	Strada Ultra 1.0 Flex Turbo CD Aut.	37
1545	Strada Volc.TRIBUTO 125 1.3 Flex CD Aut.	37
1546	Strada Volcano 1.3 Flex 8V CD	37
1547	Strada Volcano 1.3 Flex 8V CD Aut.	37
1548	Strada Working 1.4 mpi Fire Flex 8V CD	37
1549	Strada Working 1.4 mpi Fire Flex 8V CE	37
1550	Strada Working 1.4 mpi Fire Flex 8V CS	37
1551	Strada Working 1.6 mpi 16V CE	37
1552	Strada Working 1.6 mpi 16V CS	37
1553	Strada Working 1.8 mpi 8v 103cv CE	37
1554	Strada Working 1.8 mpi 8V 103cv CS	37
1555	Strada Working Celeb.1.4 Fire Flex 8V CD	37
1556	Strada Working Celeb.1.4 Fire Flex 8V CE	37
1557	Strada Working Celeb.1.4 Fire Flex 8V CS	37
1558	Strada Working HARD 1.4 Fire Flex 8V CD	37
1559	Strada Working HARD 1.4 Fire Flex 8V CE	37
1560	Strada Working HARD 1.4 Fire Flex 8V CS	37
1561	Strada Working Plus 1.4 8V Flex CS	37
1562	Strada/ Strada Working 1.5 mpi 8V CE	37
1563	Strada/ Strada Working 1.5 mpi 8V CS	37
1564	Tempra 2.0 i.e 16V 2p e 4p	37
1565	Tempra 2.0 i.e. 8V 2p e 4p	37
1566	Tempra 2.0 mpi 16V	37
1567	Tempra 8V/ City 8V	37
1568	Tempra HLX 2.0 16V 4p	37
1569	Tempra Ouro 16V 2p e 4p	37
1570	Tempra Ouro/Prata 2.0 2p e 4p	37
1571	Tempra Stile 2.0 i.e. Turbo 4p	37
1572	Tempra SW SLX 2.0 i.e.	37
1573	Tempra SX 2.0 16V 4p	37
1574	Tempra SX 2.0 i.e. 8V 4p	37
1575	Tempra Turbo 2.0 i.e. 2p	37
1576	Tipo 1.6 i.e. 2p e 4p	37
1577	Tipo 1.6 mpi 4p	37
1578	Tipo 2.0 16V 2p/4p	37
1579	Tipo 2.0 SLX 4p	37
1580	Titano Endurance 2.2 16V 4x4 TB Die. Mec	37
1581	Titano Ranch 2.2 16V 4x4 TB Diesel Aut.	37
1582	Titano Volcano 2.2 16V 4x4 TB Die. Aut.	37
1583	Toro Blackjack 2.4 16V flex Aut	37
1584	Toro Endurance 1.3 T270 4x2 Flex Aut.	37
1585	Toro Endurance 1.8 16V Flex Aut.	37
1586	Toro Endurance 1.8 16V Flex Mec.	37
1587	Toro Endurance 2.0 16V 4x4 Diesel Aut.	37
1588	Toro Freedom 1.3 T270 4x2 Flex Aut.	37
1589	Toro Freedom 1.8 16V Flex Aut.	37
1590	Toro Freedom 2.0 16V 4x2 TB Diesel Mec.	37
1591	Toro Freedom 2.0 16V 4x4 TB Diesel Aut.	37
1592	Toro Freedom 2.0 16V 4x4 TB Diesel Mec.	37
1593	Toro Freedom 2.4 16V Flex Aut.	37
1594	Toro Freedom Road 1.8 16V Flex Aut.	37
1595	Toro Freedom Road 2.4 16V Flex Aut.	37
1596	Toro Opening Ed. Plus 1.8 16V Flex Aut.	37
1597	Toro Opening Edition 1.8 16V Flex Aut.	37
1598	Toro Ranch 2.0 16V 4x4 TB Diesel Aut.	37
1599	Toro Ranch 2.2 16V 4x4 TB Diesel Aut.	37
1600	Toro Ultra 1.3 16V 4x2 TB Flex Aut.	37
1601	Toro Ultra 2.0 16V 4x4 TB Diesel Aut.	37
1602	Toro Vol. TRIBUTO 125 1.3 T270 Flex Aut.	37
1603	Toro Volcano 1.3 T270 4x2 Flex Aut.	37
1604	Toro Volcano 2.0 16V 4x4 TB Diesel Aut.	37
1605	Toro Volcano 2.2 16V 4x4 TB Diesel Aut.	37
1606	Toro Volcano 2.4 16V Flex Aut.	37
1607	Uno 1.6 mpi 2p e 4p	37
1608	Uno 1.6R mpi / 1.6R / 1.5R	37
1609	UNO ATTRACTI. Celeb.1.4 EVO F.Flex 8V 2p	37
1610	UNO ATTRACTI. Celeb.1.4 EVO F.Flex 8V 4p	37
1611	UNO ATTRACTIVE 1.0 Fire Flex 8V 5p	37
1612	UNO ATTRACTIVE 1.0 Flex 6V 5p	37
1613	UNO ATTRACTIVE 1.4 EVO Fire Flex 8V 2p	37
1614	UNO ATTRACTIVE 1.4 EVO Fire Flex 8V 4p	37
1615	UNO CIAO 1.0 Fire Flex 8V 5p	37
1616	Uno City / Smart City 1.0 4p	37
1617	Uno CS/Top/Sport 1.5 i.e. / 1.5 /1.3	37
1618	Uno CS/Top/Sport 1.5 i.e. / 1.5 4p	37
1619	Uno CSL 1.6 4p (Argentino)	37
1620	UNO DRIVE 1.0 Flex 6V 5p	37
1621	UNO ECONOMY 1.4 EVO Fire Flex 8V 2p	37
1622	UNO ECONOMY 1.4 EVO Fire Flex 8V 4p	37
1623	UNO ECONOMY Celeb. 1.4 EVO F. Flex 8V 2p	37
1624	UNO ECONOMY Celeb. 1.4 EVO F. Flex 8V 4p	37
1625	UNO EVOLUTION 1.4 Fire Flex 8V 5p	37
1626	UNO Furgão 1.0 Fire Flex 8V 3p	37
1627	Uno Furgão 1.3 mpi Fire/ Fire Flex 8V	37
1628	Uno Furgão 1.5 mpi/i.e.	37
1629	Uno Furgão 1.5/ 1.3	37
1630	Uno Mille  ELX  2p e 4p	37
1631	Uno Mille 1.0 Electronic 4p	37
1632	Uno Mille 1.0 Fire/ F.Flex/ ECONOMY 2p	37
1633	Uno Mille 1.0 Fire/ F.Flex/ ECONOMY 4p	37
1634	Uno Mille 1.0/ i.e./Electronic/Brio 2p	37
1635	Uno Mille Celeb. WAY ECON. 1.0 F.Flex 2p	37
1636	Uno Mille Celeb. WAY ECON. 1.0 F.Flex 4p	37
1637	Uno Mille Celeb/Celeb.ECON 1.0 F.Flex 2p	37
1638	Uno Mille Celeb/Celeb.ECON 1.0 F.Flex 4p	37
1639	Uno Mille EP 2p e 4p	37
1640	Uno Mille Grazie 1.0 Fire Flex 8v 4p	37
1641	Uno Mille SX 2p e 4p	37
1642	Uno Mille SX Young 1.0 IE	37
1643	UNO MILLE WAY ECO.XINGU 1.0 F.Flex 8v 5p	37
1644	Uno Mille WAY ECONOMY 1.0 F.Flex 2p	37
1645	Uno Mille WAY ECONOMY 1.0 F.Flex 4p	37
1646	Uno Mille/ Mille EX/ Smart 2p	37
1647	Uno Mille/ Mille EX/ Smart 4p	37
1648	Uno S 1.5 i.e. / 1.5 / 1.3/ SX 1.3	37
1649	UNO SPORT. Dual. 1.4 B.Edit. Flex 8V 5p	37
1650	UNO SPORT.INTERLAGOS 1.4 EVO F.Flex 8v	37
1651	UNO SPORTING 1.3 Flex 8V 5p	37
1652	UNO SPORTING 1.4 B.Edit. Flex 8V 5p	37
1653	UNO SPORTING 1.4 EVO Fire Flex 8V 2p	37
1654	UNO SPORTING 1.4 EVO Fire Flex 8V 4p	37
1655	UNO SPORTING Dual./GSR 1.3 Flex 8V 5p	37
1656	UNO SPORTING Dualogic 1.4 EVO Flex 8V 4p	37
1657	Uno Turbo 1.4 i.e. 2p	37
1658	UNO VIVACE 1.0 EVO Fire Flex 8V 3p	37
1659	UNO VIVACE Celeb. 1.0 EVO F. Flex 8V 3p	37
1660	UNO VIVACE Celeb. 1.0 EVO F.Flex 8V 5p	37
1661	UNO VIVACE College 1.0 EVO FireFlex 5p	37
1662	UNO VIVACE ITALIA 1.0 EVO F. Flex 8V 5p	37
1663	UNO VIVACE/RUA 1.0 EVO Fire Flex 8V 5p	37
1664	UNO WAY 1.0 EVO Fire Flex 8V 2p	37
1665	UNO WAY 1.0 EVO Fire Flex 8V 5p	37
1666	UNO WAY 1.0 Flex 6V 5p	37
1667	UNO WAY 1.3 Flex 8V 5p	37
1668	UNO WAY 1.4 EVO Dualogic Flex 8V 5p	37
1669	UNO WAY 1.4 EVO Fire Flex 8V 2p	37
1670	UNO WAY 1.4 EVO Fire Flex 8V 5p	37
1671	UNO WAY Celeb. 1.0 EVO Fire Flex 8V 2p	37
1672	UNO WAY Celeb. 1.0 EVO Fire Flex 8V 5p	37
1673	UNO WAY Celeb. 1.4 EVO Fire Flex 8V 2p	37
1674	UNO WAY Celeb. 1.4 EVO Fire Flex 8V 5p	37
1675	UNO WAY Dual./GSR 1.3 Flex 8V 5p	37
1676	UNO WAY RIO 450 1.0 EVO Flex 8V 5p	37
1677	UNO WAY XINGU 1.0 EVO F.Flex 8V 5P	37
1678	UNO WAY XINGU 1.4 EVO F.Flex 8V 5p	37
1679	A-10 2.5/4.1	44
1680	A-10 De Luxe 2.5/4.1	44
1681	A-20 Custom Std. CD/ De Luxe CD	44
1682	A-20 Custom/ C-20 Luxe 4.1	44
1683	A-20 Custom/ C-20 S 4.1	44
1684	AGILE LT 1.4 MPFI 8V FlexPower 5p	44
1685	AGILE LTZ 1.4 MPFI 8V FlexPower 5p	44
1686	AGILE LTZ EASYTRONIC 1.4 8V FlexPower 5p	44
1687	AGILE LTZ EFFECT 1.4 8V FlexPower 5p Mec	44
1688	AGILE LTZ EFFECT EASYTR.1.4 8V FlexP. 5p	44
1689	AGILE LTZ WI-FI 1.4 8V FlexPower 5p	44
1690	Astra 2.0 8V/ CD 2.0 8V Hatchback 5p Aut	44
1691	Astra 2.0 8V/ CD 2.0 8V Hatchback 5p Mec	44
1692	Astra 2.0/ CD 2.0 8V 3p Aut.	44
1693	Astra 2.0/ CD/ GLS 2.0 MPFI 16V 3p	44
1694	Astra 2.0/ CD/ Sunny/ GLS 2.0 8V 3p	44
1695	Astra 500 Sedan 2.0 MPFI 16V 4p	44
1696	Astra Advant. 2.0 MPFI 8V FlexP. 5p Aut.	44
1697	Astra Advantage 2.0 MPFI 8V FlexPower 5p	44
1698	Astra Advantage 2.0 MPFI FlexPower 8V 3p	44
1699	Astra Comfort 2.0 MPFI FlexPower 8V 3p	44
1700	Astra Comfort 2.0 MPFI FlexPower 8V 5p	44
1701	Astra Eleg. 2.0 MPFI FlexPower 8V 5p Aut	44
1702	Astra Elegance 2.0 MPFI FlexPower 8V 3p	44
1703	Astra Elegance 2.0 MPFI FlexPower 8V 5p	44
1704	Astra Elite 2.0 MPFI Flex Pow. 8V 5p Aut	44
1705	Astra Elite 2.0 MPFI FlexPower 8V 5p Mec	44
1706	Astra GL 1.8 MPFI 3p	44
1707	Astra GL Milenium 1.8 MPFI 4p	44
1708	Astra GLS 2.0 MPFI	44
1709	Astra GLS 2.0 MPFI SW	44
1710	Astra GSi 2.0 16V 136cv Hatchback 5p	44
1711	Astra S.Sport 2.0 F.Pow. 5p/Sport 2.0 3p	44
1712	Astra Sed. Advant. 2.0 8V MPFI FlexP. 4p	44
1713	Astra Sed.Advan. 2.0 8V MPFI FlexP. Aut.	44
1714	Astra Sed.Comf. 2.0 MPFI FlexPower 8V 4p	44
1715	Astra Sed.Comf.2.0 MPFI MultiPower 8V 4p	44
1716	Astra Sed.Eleg. 2.0 MPFI FlexP.8V Aut.	44
1717	Astra Sed.Eleg.2.0 MPFI FlexPower 8V 4p	44
1718	Astra Sed.Eleg.2.0 MPFI MultiPower 8V 4p	44
1719	Astra Sed.Elite 2.0 MPFI FlexP.8V Aut.	44
1720	Astra Sed.Elite 2.0 MPFI FlexPower 8V 4p	44
1721	Astra Sedan 1.8 MPFI 8V 4p	44
1722	Astra Sedan 2.0/ CD 2.0 MPFI 8V 4p Aut.	44
1723	Astra Sedan 2.0/CD/ Expres.GLS 2.0 8V 4p	44
1724	Astra Sedan 2.0/CD/ GLS/ Adv. 2.0 16V 4p	44
1725	Astra Sedan Comfort 1.8 MPFI 8V 4p	44
1726	Astra Sedan GL 1.8 MPFI 4p	44
1727	BLAZER EV RS 347cv (Elétrico)	44
1728	Blazer Jimmy 4.3 V6	44
1729	Blazer S-10 4.3 V6	44
1730	Blazer SS-10 4.3 V6	44
1731	BOLT EUV Premier 203cv (Elétrico)	44
1732	BOLT EV Premier 203cv (Elétrico)	44
1733	Bonanza S / Luxe 4.0 Diesel Turbo	44
1734	Bonanza S / Luxe 4.1	44
1735	Brasinca Blazer CD 4.0 Diesel	44
1736	Brasinca Blazer CD 4.1	44
1737	C-10 2.5/4.1	44
1738	C-10 CD 2.5/ 4.1	44
1739	C-10 De Luxe 2.5/4.1	44
1740	C-10 De Luxe CD 2.5/ 4.1	44
1741	C-20 Custom De Luxe 4.1	44
1742	C-20 Custom De Luxe CD 4.1	44
1743	C-20 Custom Std. 4.1	44
1744	C-20 Custom Std. CD 4.1	44
1745	Calibra 16V	44
1746	CAMARO FIFTY 6.2 V8 16V 461cv	44
1747	Camaro RS 5.0 V8	44
1748	Camaro Sport 5.0 Conv.	44
1749	Camaro SS 6.2 V8 16V	44
1750	Camaro SS Collection 6.2 V8 16V	44
1751	Camaro SS Conversível 6.2 V8 16V	44
1752	Camaro Z-28 Targa/Conv. 5.7	44
1753	Caprice 4.3 V8	44
1754	Caprice SW 4.3 V8	44
1755	Caprice Victoria	44
1756	CAPTIVA EV Premier	44
1757	CAPTIVA SPORT AWD 3.0 V6 24V 268cv	44
1758	CAPTIVA SPORT AWD 3.6 V6 24V 261cv 4x4	44
1759	CAPTIVA SPORT FWD 2.4 16V 171/185cv	44
1760	CAPTIVA SPORT FWD 3.0 V6 24V 268cv 4x2	44
1761	CAPTIVA SPORT FWD 3.6 V6 24V 261cv 4x2	44
1762	Caravan Comodoro 4.1/2.5	44
1763	Caravan Diplomata 4.1/2.5	44
1764	Caravan L/SL/S/SS 2.5/4.1/4.2	44
1765	Cavalier 3.1 Conv.	44
1766	Cavalier L 2.0	44
1767	Celta 1.0/ Super 1.0 MPFI VHC 8v 5p	44
1768	Celta 1.0/Super/N.Piq.1.0 MPFi VHC 8V 3p	44
1769	Celta 1.4/ Super/ Energy 1.4 8V 85cv 3p	44
1770	Celta 1.4/ Super/ Energy 1.4 8V 85cv 5p	44
1771	Celta ADVANTAGE 1.0 8v FlexPower 5p	44
1772	Celta Life 1.0 MPFI VHC 8V 3p	44
1773	Celta Life 1.0 MPFI VHC 8V 5p	44
1774	Celta Life 1.4 MPFI 8V 85cv 3p	44
1775	Celta Life 1.4 MPFI 8V 85cv 5p	44
1776	Celta Life/ LS 1.0 MPFI 8V FlexPower 3p	44
1777	Celta Life/ LS 1.0 MPFI 8V FlexPower 5p	44
1778	Celta Spirit 1.0 MPFI 8V FlexPower 3p	44
1779	Celta Spirit 1.0 MPFI VHC 8V 3p	44
1780	Celta Spirit 1.0 MPFI VHC 8V 5p	44
1781	Celta Spirit 1.4 MPFI 8V 85cv 3p	44
1782	Celta Spirit 1.4 MPFI 8V 85cv 5p	44
1783	Celta Spirit/ LT 1.0 MPFI 8V FlexP. 5p	44
1784	Celta Super 1.0 MPFI 8V FlexPower 3p	44
1785	Celta Super 1.0 MPFI 8V FlexPower 5p	44
1786	Chevette Junior 1.0	44
1787	Chevette L / SL / SL/e / DL / SE 1.6	44
1788	Chevy 500 DL / SL / SE/ Furgão 1.6	44
1789	Cheynne 4.3 V6	44
1790	Classic ADVANTAGE 1.0 VHC FlexPower 4p	44
1791	Classic Life/LS 1.0 VHC FlexP. 4p	44
1792	COBALT 1.8 8V Econo.Flex 4p Aut.	44
1793	COBALT ADVANTAGE 1.4 MPFI 8V F.Power 4p	44
1794	COBALT ADVANTAGE 1.8 8V Eco.Flex 4p Aut.	44
1795	COBALT ELITE 1.8 8V Econo.Flex 4p Aut.	44
1796	COBALT Graphite 1.8 8V Econo.Flex 4p Aut	44
1797	COBALT Graphite 1.8 8V Econo.Flex 4p Mec	44
1798	COBALT LS 1.4 8V FlexPower 4p	44
1799	COBALT LT 1.4 8V FlexPower/EconoFlex 4p	44
1800	COBALT LT 1.8 8V Econo.Flex 4p Aut.	44
1801	COBALT LT 1.8 8V Econo.Flex 4p Mec.	44
1802	COBALT LTZ 1.4 8V FlexPower/EconoFlex 4p	44
1803	COBALT LTZ 1.8 8V Econo.Flex 4p Aut.	44
1804	COBALT LTZ 1.8 8V Econo.Flex 4p Mec.	44
1805	Corsa Furgão 1.6 MPFi Powertech 92cv	44
1806	Corsa GL 1.6 MPFI / 1.4 EFI 2p e 4p	44
1807	Corsa GLS 1.6 MPFI 5p	44
1808	Corsa GSi 16V	44
1809	Corsa Hat. Joy 1.0/ 1.0 FlexPower 8V 5p	44
1810	Corsa Hat. Joy 1.8 MPFI 8V FlexPower 5p	44
1811	Corsa Hat. Maxx 1.0/ 1.0 FlexPower 8V 5p	44
1812	Corsa Hat. Maxx 1.4 8V ECONOFLEX 5p	44
1813	Corsa Hat. Maxx 1.8 MPFI 8V FlexPower 5p	44
1814	Corsa Hat. Prem. 1.0/1.0 FlexPower 8V 5p	44
1815	Corsa Hat. Premium 1.4 8V ECONOFLEX 5p	44
1816	Corsa Hat. SS 1.8 MPFI 8V FlexPower 5p	44
1817	Corsa Hat.Premium 1.8 MPFI 8V F.Power 5p	44
1818	Corsa Hatchback 1.0 MPFI 8V 71cv 5p	44
1819	Corsa Hatchback 1.8 MPFI 8V 102cv 5p	44
1820	Corsa Hatchback 1.8 MPFI FlexPower 8V 5p	44
1821	Corsa Pick-Up GL/ Champ 1.6 MPFI / EFI	44
1822	Corsa Pick-Up Sport 1.6 MPFI	44
1823	Corsa Pick-Up STD/ Rodeio 1.6 MPFI	44
1824	Corsa Sed Clas.Spirit 1.6MPFI VHC 8V Aut	44
1825	Corsa Sed Clas.Super 1.6MPFI VHC 8V Aut	44
1826	Corsa Sed Class.Life 1.0/1.0 FlexPower	44
1827	Corsa Sed Class.Spirit 1.0/1.0 FlexPower	44
1828	Corsa Sed Class.Super 1.0/1.0 FlexPower	44
1829	Corsa Sed Classic Life 1.6 MPFI VHC 8V	44
1830	Corsa Sed Classic Spirit 1.6 MPFI VHC 8V	44
1831	Corsa Sed Classic Super 1.6 MPFI VHC 8V	44
1832	Corsa Sed. Joy 1.0/ 1.0 FlexPower 8V 4p	44
1833	Corsa Sed. Joy 1.8 MPFI 8V FlexPower	44
1834	Corsa Sed. Maxx 1.0/ 1.0 FlexPower 8V 4p	44
1835	Corsa Sed. Maxx 1.4 8V ECONOFLEX 4p	44
1836	Corsa Sed. Maxx 1.8 MPFI 8V FlexPower	44
1837	Corsa Sed. Premium 1.4 8V ECONOFLEX 4p	44
1838	Corsa Sed. Premium 1.8 MPFI 8V FlexPower	44
1839	Corsa Sed.Prem. 1.0/ 1.0 FlexPower 8V 4p	44
1840	Corsa Sed.Wind 1.0/Millenium/Classic VHC	44
1841	Corsa Sedan 1.0 MPFI 8V 71cv 4p	44
1842	Corsa Sedan 1.8 MPFI 8V  102cv 4p	44
1843	Corsa Sedan 1.8 MPFI FlexPower 8V 4p	44
1844	Corsa Sedan GL 1.6  MPFI 4p	44
1845	Corsa Sedan GLS 1.6 16V MPFI 4p	44
1846	Corsa Sedan GLS 1.6 MPFI 4p	44
1847	Corsa Sedan Sup./Classic 1.6 8v Aut/Mec	44
1848	Corsa Sedan Super 1.0 MPFI 16V 4p	44
1849	Corsa Sedan Super 1.0 MPFI 4p	44
1850	Corsa Sedan Super Milenium 1.0 MPFI 16V	44
1851	Corsa Super 1.0 MPFI / 2p e 4p	44
1852	Corsa Super 1.0 MPFI 16V 3p	44
1853	Corsa Super 1.0 MPFI 16V 5p	44
1854	Corsa Super 1.6 MPFI 8v 5p	44
1855	Corsa Wagon GL 1.6 MPFI 4p	44
1856	Corsa Wagon GLS 1.6 16V MPFI 4p	44
1857	Corsa Wagon GLS 1.6 8V 4p	44
1858	Corsa Wagon Super 1.0 MPFI 16V	44
1859	Corsa Wagon Super 1.6 MPFI 8v	44
1860	Corsa Wind 1.0 MPF/MilleniumI/ EFI 4p	44
1861	Corsa Wind 1.0 MPFI / EFI  2p	44
1862	Corsa Wind 1.6 MPFi 2p	44
1863	Corsa Wind 1.6 MPFi 4p	44
1864	Corsa Wind Piquet/ Champ 1.0 MPFI 2p	44
1865	Corvette 5.7/ 6.0, 6.2 Conv./Stingray	44
1866	Corvette 5.7/ 6.0, 6.2 Targa/Stingray	44
1867	CRUZE Black Bow Tie 1.4 TB Flex 4p Aut	44
1868	CRUZE HB Black Bow Tie 1.4 TB Flex Aut.	44
1869	CRUZE HB Sport LT 1.8 16V FlexP. 5p Aut	44
1870	CRUZE HB Sport LT 1.8 16V FlexP. 5p Mec	44
1871	CRUZE HB Sport LTZ 1.8 16V FlexP. 5p Aut	44
1872	CRUZE HB Sport LTZ 1.8 16V FlexP. 5p Mec	44
1873	CRUZE LT 1.4 16V Turbo Flex 4p Aut.	44
1874	CRUZE LT 1.8 16V FlexPower 4p Aut.	44
1875	CRUZE LT 1.8 16V FlexPower 4p Mec.	44
1876	CRUZE LTZ 1.4 16V Turbo Flex 4p Aut.	44
1877	CRUZE LTZ 1.8 16V FlexPower 4p Aut.	44
1878	CRUZE Midnight 1.4 16V TB Flex Aut.	44
1879	CRUZE Premier 1.4 16V TB Flex Aut.	44
1880	CRUZE Sport LT 1.4 16V TB Flex 5p Aut.	44
1881	CRUZE Sport LTZ 1.4 16V TB Flex 5p Aut.	44
1882	CRUZE Sport Premier 1.4 16V TB Flex Aut.	44
1883	CRUZE Sport RS 1.4 16V TB Flex 5p Aut.	44
1884	D-10 CD Diesel	44
1885	D-10 Diesel	44
1886	D-20 4.0 Champ/Conquest/El Caminho Dies.	44
1887	D-20 CD Lx S4T/Tro.Plus/Lx 3.9/4.0 TDies	44
1888	D-20 S / El Caminho 3.9/4.0 CD T.Dies	44
1889	D-20 S / Luxe 3.9/4.0 Diesel	44
1890	D-20 S / Luxe 3.9/4.0 T.Diesel	44
1891	D-20 S 3.9/4.0 Turbo Diesel	44
1892	EQUINOX ACTIV 1.5 Turbo 177cv Aut.	44
1893	EQUINOX EV 292cv (Elétrico)	44
1894	EQUINOX LT 1.5 Turbo 172cv Aut.	44
1895	EQUINOX LT 2.0 Turbo 262cv Aut.	44
1896	EQUINOX Midnight 1.5 Turbo 172cv Aut.	44
1897	EQUINOX Premier 1.5 Turbo 172cv Aut.	44
1898	EQUINOX Premier 2.0 Turbo AWD 262cv Aut.	44
1899	EQUINOX RS 1.5 Turbo  Aut.	44
1900	Ipanema GL 1.8 MPFI / EFI /SL 4p	44
1901	Ipanema GL/ Flair 2.0 MPFI / EFI 4p	44
1902	Ipanema GLS/SLE 2.0EFI /SL/e1.8/Sol/Wave	44
1903	JOY Hatch 1.0 8V Black Edition Flex Mec.	44
1904	JOY Hatch 1.0 8V Flex 5p Mec.	44
1905	JOY Plus 1.0 8V 4p Flex Mec.	44
1906	JOY Plus Black Ed.1.0 8V 4p Flex Mec.	44
1907	Kadett GL 2.0 MPFI / EFI	44
1908	Kadett GL/SL/Lite/Turim 1.8	44
1909	Kadett GLS 1.8 EFI / SL/e 1.8	44
1910	Kadett GLS 2.0 MPFI	44
1911	Kadett GSi / GS 2.0	44
1912	Kadett GSi 2.0 Conversível	44
1913	Kadett Sport 2.0 MPFI / EFI	44
1914	Lumina	44
1915	MALIBU LTZ 2.4 16V 171cv 4p	44
1916	Marajo SL/SLe/Se	44
1917	Meriva 1.8/ CD 1.8 MPFI 16V 122cv 5p	44
1918	Meriva 1.8/ CD 1.8 MPFI 8V 102cv 5p	44
1919	Meriva 1.8/ CD 1.8 MPFI FlexPower 8V	44
1920	Meriva COLLECTION 1.4 8V ECONOFLEX 5p	44
1921	Meriva Expres.EASYTRONIC 1.8 FlexPower	44
1922	Meriva Joy 1.4 MPFI 8V ECONOFLEX 5p	44
1923	Meriva Joy 1.8 MPFI 8V FlexPower	44
1924	Meriva Maxx 1.4 MPFI 8V ECONOFLEX 5p	44
1925	Meriva Maxx 1.8 MPFI 8V FlexPower	44
1926	Meriva Prem.EASYTRONIC 1.8 FlexPower 5p	44
1927	Meriva Premium 1.8 MPFI 8V FlexPower	44
1928	Meriva SS 1.8 MPFI 8V FlexPower 5p	44
1929	Meriva SS EASYTRONIC 1.8 FlexPower 5p	44
1930	MONTANA  Sport 1.8 MPFI FlexPower 8V	44
1931	MONTANA 1.2 Turbo Flex 12V 4p Mec.	44
1932	MONTANA 1.4 8V Conquest ECONOFLEX  2p	44
1933	MONTANA 1.8/ 1.8 Conquest FlexPower 8V	44
1934	MONTANA ARENA 1.4 ECONOFLEX  8V 2p	44
1935	MONTANA COMBO 1.4 8V ECONOFLEX	44
1936	MONTANA LS 1.4 ECONOFLEX 8V 2p	44
1937	MONTANA LS COMBO 1.4 8V ECONOFLEX 2p	44
1938	MONTANA LT 1.2  Turbo Flex 12V 4p Mec.	44
1939	MONTANA LTZ 1.2 Turbo Flex 12V 4p Aut.	44
1940	MONTANA Off Road 1.8 MPFI FlexPower 8V	44
1941	MONTANA PREMIER 1.2 Turbo Flex 12V Aut.	44
1942	MONTANA RS 1.2 Turbo Flex 12V Aut.	44
1943	MONTANA Sport 1.4 ECONOFLEX 8V 2p	44
1944	Monza 1.6i/1.8i (restante)	44
1945	Monza Class 1.8/ 2.0	44
1946	Monza Classic SE 2.0 /MPFI e EFI 2p e 4p	44
1947	Monza Classic/ SL/e/SR 1.8	44
1948	Monza GL 1.8 EFI/ SL/ L/ 650/Barc. 2e4p	44
1949	Monza GL 2.0 EFI/SL/L/650/Club/Barc.2e4p	44
1950	Monza GLS/ Hi-Tech 2.0 EFI 2p e 4p	44
1951	Monza SL/e SR 2.0	44
1952	Omega CD 3.8 V6	44
1953	Omega CD 4.1 / 3.0	44
1954	Omega CD/ FITTIPALDI 3.6 V6 24V 4p	44
1955	Omega Diamond	44
1956	Omega GL 2.0/ 2.2	44
1957	Omega GLS 2.2 / 2.0	44
1958	Omega GLS 4.1	44
1959	ONIX  Lollapalooza 1.0 F.Power 5p Mec.	44
1960	ONIX HATCH 1.0 12V Flex 5p Mec.	44
1961	ONIX HATCH 1.0 12V TB 5p Mec.	44
1962	ONIX HATCH 1.0 12V TB Flex 5p Aut.	44
1963	ONIX HATCH 100 Anos 1.0 12V 5p Mec.	44
1964	ONIX HATCH ACTIV 1.4 8V Flex 5P Aut.	44
1965	ONIX HATCH ACTIV 1.4 8V Flex 5p Mec.	44
1966	ONIX HATCH ADVANTAGE 1.4 8V Flex 5p Aut.	44
1967	ONIX HATCH EFFECT 1.4 8V F.Power 5p Mec.	44
1968	ONIX HATCH Joy 1.0 8V Flex 5p Mec.	44
1969	ONIX HATCH LS 1.0 8V FlexPower 5p Mec.	44
1970	ONIX HATCH LT 1.0 12V Flex 5p Mec.	44
1971	ONIX HATCH LT 1.0 12V TB Flex 5p Aut.	44
1972	ONIX HATCH LT 1.0 12V TB Flex 5p Mec.	44
1973	ONIX HATCH LT 1.0 8V FlexPower 5p Mec.	44
1974	ONIX HATCH LT 1.4 8V FlexPower 5p Aut.	44
1975	ONIX HATCH LT 1.4 8V FlexPower 5p Mec.	44
1976	ONIX HATCH LTZ 1.0 12V TB Flex 5p Aut.	44
1977	ONIX HATCH LTZ 1.0 12V TB Flex 5p Mec.	44
1978	ONIX HATCH LTZ 1.4 8V FlexPower 5p Aut.	44
1979	ONIX HATCH LTZ 1.4 8V FlexPower 5p Mec.	44
1980	ONIX HATCH PREM. 1.0 12V TB Flex 5p Aut.	44
1981	ONIX HATCH RS 1.0 TB 12V Flex 5p Aut.	44
1982	ONIX HATCH SELEÇÃO 1.0 8V Flex 5p Mec.	44
1983	ONIX SD. P. PR. MIDNIGHT 1.0 TB Flex Aut	44
1984	ONIX SED. Plus PREM. 1.0 12V TB Flex Aut	44
1985	ONIX SEDAN Plus 1.0 12V Mec.	44
1986	ONIX SEDAN Plus 1.0 12V TB Flex Aut.	44
1987	ONIX SEDAN Plus 1.0 12V TB Flex Mec.	44
1988	ONIX SEDAN Plus LT 1.0 12V Flex 4p Mec.	44
1989	ONIX SEDAN Plus LT 1.0 12V TB Flex Aut.	44
1990	ONIX SEDAN Plus LT 1.0 12V TB Flex Mec.	44
1991	ONIX SEDAN Plus LTZ 1.0 12V TB Flex Aut.	44
1992	ONIX SEDAN Plus LTZ 1.0 12V TB Flex Mec.	44
1993	Opala Comodoro/Comod. SLE  4.1/2.5	44
1994	Opala Diplomata/Diplom. SLE/SE 4.1/2.5	44
1995	Opala L/SL/SS/ 2.5/4.1	44
1996	PRISMA  Sed. Maxx/ LT 1.4 8V ECONOF. 4p	44
1997	PRISMA Sed. ADVANT. 1.0 8V FlexPower 4p	44
1998	PRISMA Sed. ADVANT. 1.4 8V F.Power Aut.	44
1999	PRISMA Sed. Joy 1.4 8V ECONOFLEX 4p	44
2000	PRISMA Sed. Joy/ LS 1.0 8V FlexPower 4p	44
2001	PRISMA Sed. LT 1.0 8V FlexPower 4p	44
2002	PRISMA Sed. LT 1.4 8V FlexPower 4p	44
2003	PRISMA Sed. LT 1.4 8V FlexPower 4p Aut.	44
2004	PRISMA Sed. LTZ 1.4 8V FlexPower 4p	44
2005	PRISMA Sed. LTZ 1.4 8V FlexPower 4p Aut.	44
2006	PRISMA Sed. Maxx 1.0 8V FlexPower 4p	44
2007	S10 Blazer  DTi 2.8 4x2 Turbo Diesel	44
2008	S10 Blazer 2.4 MPFI 8V 128cv 4p	44
2009	S10 Blazer 4.3 V6	44
2010	S10 Blazer Advant. 2.4/2.4 MPFI F.Power	44
2011	S10 Blazer Colina 2.4/2.4 MPFI F.Power	44
2012	S10 Blazer Colina 2.8 TDI 4x4 Diesel	44
2013	S10 Blazer DLX 2.2 MPFI / EFI	44
2014	S10 Blazer DLX 2.4 MPFI 128cv 4p	44
2015	S10 Blazer DLX 2.5 Diesel Turbo	44
2016	S10 Blazer DLX 2.8 4x4 TB Interc. Diesel	44
2017	S10 Blazer DLX 4.3 V6	44
2018	S10 Blazer Executive 2.8 4x4 TDI Diesel	44
2019	S10 Blazer Executive 4.3 V6	44
2020	S10 Blazer Std. 2.2 MPFI / EFI	44
2021	S10 Blazer Std. 2.5 Diesel Turbo	44
2022	S10 Blazer Tornado 2.4 MPFI 8V 128cv	44
2023	S10 P.Up 100YEARS 2.8 4x4 CD Dies. Aut.	44
2024	S10 Pick-Up 100 Anos 2.8 TDI 4x4 CD Aut.	44
2025	S10 Pick-Up 2.4 MPFI 8v 128cv CD 4p	44
2026	S10 Pick-Up 2.4 MPFI 8v 128cv/ Rodeio	44
2027	S10 Pick-Up 2.5 4x2 CD TB Max HST Dies	44
2028	S10 Pick-Up 2.5 4x4 CD TB Max HST Dies.	44
2029	S10 Pick-Up 2.8 4x2 Turbo Interc. Dies.	44
2030	S10 Pick-Up 4.3 V6	44
2031	S10 Pick-Up Advantage 2.5 Flex 4x2 CD	44
2032	S10 Pick-Up Barretos 2.2 MPFI 2p	44
2033	S10 Pick-Up Champ 4.3 V6	44
2034	S10 Pick-Up DLX 2.4 MPFI 128cv CD 4p	44
2035	S10 Pick-Up Exec. 2.8 4x2 CD TB Int.Dies	44
2036	S10 Pick-Up Exec. 2.8 4x4 CD TB Int.Dies	44
2037	S10 Pick-Up Executive CD 4.3	44
2038	S10 Pick-Up Executive CD 4.3 4x4	44
2039	S10 Pick-Up LS 2.4 F.Power 4x2 CD	44
2040	S10 Pick-Up LS 2.4 F.Power 4x2 CS	44
2041	S10 Pick-Up LS 2.8 TDI 4x2 CD Dies. Mec.	44
2042	S10 Pick-Up LS 2.8 TDI 4x2 CS Dies. Mec.	44
2043	S10 Pick-Up LS 2.8 TDI 4x4 CD Dies. Mec.	44
2044	S10 Pick-Up LS 2.8 TDI 4x4 CS Diesel	44
2045	S10 Pick-Up LT 2.4 F.Power 4x2 CD	44
2046	S10 Pick-Up LT 2.4 F.Power 4x2 CS	44
2047	S10 Pick-Up LT 2.5 Flex 4x2 CD	44
2048	S10 Pick-Up LT 2.5 Flex 4x2 CD Aut.	44
2049	S10 Pick-Up LT 2.5 Flex 4x4 CD	44
2050	S10 Pick-Up LT 2.5 Flex 4x4 CD Aut.	44
2051	S10 Pick-Up LT 2.8 TDI 4x2 CD Diesel	44
2052	S10 Pick-Up LT 2.8 TDI 4x2 CD Diesel Aut	44
2053	S10 Pick-Up LT 2.8 TDI 4x4 CD Diesel	44
2054	S10 Pick-Up LT 2.8 TDI 4x4 CD Diesel Aut	44
2055	S10 Pick-Up LTZ 2.4 F.Power 4x2 CD	44
2056	S10 Pick-Up LTZ 2.5 Flex 4x2 CD	44
2057	S10 Pick-Up LTZ 2.5 Flex 4x2 CD Aut.	44
2058	S10 Pick-Up LTZ 2.5 Flex 4x4 CD	44
2059	S10 Pick-Up LTZ 2.5 Flex 4x4 CD Aut.	44
2060	S10 Pick-Up LTZ 2.8 TDI 4x2 CD Dies. Mec	44
2061	S10 Pick-Up LTZ 2.8 TDI 4x2 CD Dies.Aut	44
2062	S10 Pick-Up LTZ 2.8 TDI 4x4 CD Dies.Aut	44
2063	S10 Pick-Up Luxe 2.2 EFI CD	44
2064	S10 Pick-Up Luxe 2.2 MPFI / EFI	44
2065	S10 Pick-Up Luxe 2.2 MPFI/EFI CE	44
2066	S10 Pick-Up Luxe 2.5 CE TB Diesel	44
2067	S10 Pick-Up Luxe 2.5 Diesel Turbo	44
2068	S10 Pick-Up Luxe 2.8 4x2 CD TB Int.Dies.	44
2069	S10 Pick-Up Luxe 4.3 V6	44
2070	S10 Pick-Up Luxe 4.3 V6 CD	44
2071	S10 Pick-Up Luxe 4.3 V6 CE	44
2072	S10 Pick-Up Midnight 2.8 4x4 CD Dies Aut	44
2073	S10 Pick-Up RODEIO 2.4 MPFI F.Power CD	44
2074	S10 Pick-Up RODEIO 2.8 TDI 4x2 CD Dies.	44
2075	S10 Pick-Up RODEIO 2.8 TDI 4x4 CD Dies.	44
2076	S10 Pick-Up Std 2.8 4x2 CD TB Int.Dies.	44
2077	S10 Pick-Up Std 2.8 4x4 CD TB Int.Dies.	44
2078	S10 Pick-Up Std. 2.2 MPFI / EFI	44
2079	S10 Pick-Up Std. 2.2 MPFI CD	44
2080	S10 Pick-Up Std. 2.5 Diesel Turbo	44
2081	S10 Pick-Up Tornado 2.4 MPFI 128cv CD 4p	44
2082	S10 Pick-Up WT 2.8 TDI 4x4 CD Diesel Aut	44
2083	S10 Pick-Up WT 2.8 TDI 4x4 CD Diesel Mec	44
2084	S10 Pick-Up WT 2.8 TDI 4x4 CS Diesel Mec	44
2085	S10 Pick-Up Z71 2.8 TDI 4x4 CD Dies. Aut	44
2086	S10 P-Up 2.8/Sert. 2.8 4x4 TB Int. Dies.	44
2087	S10 P-Up Advant. 2.4/2.4 MPFI F.Power CD	44
2088	S10 P-Up Advantage 2.4 MPFI F.Power CS	44
2089	S10 P-Up Colina 2.4 MPFI 128cv CD 4p	44
2090	S10 P-Up Colina 2.4/2.4 MPFI F.Power CS	44
2091	S10 P-Up Colina 2.8 TDI 4x2/4x4 CD Dies.	44
2092	S10 P-Up Colina 2.8 TDI 4x2/4x4 CS Dies.	44
2093	S10 P-Up Executive 2.4 MPFI F.Power CD	44
2094	S10 P-Up Freeride 2.5 Flex 4x2 CD Mec.	44
2095	S10 P-Up H.Country 2.8 4x4 CD Dies.Aut.	44
2096	S10 P-Up Luxe 2.5 4x2 CD TB Max HST Dies	44
2097	S10 P-Up Luxe 2.5 4x4 CD TB Max HST Dies	44
2098	S10 P-Up Lx/Sert/Rod 2.8 4x4 CD TDI Dies	44
2099	S10 P-Up Tornado 2.8 TDI 4x2/4x4 CD Dies	44
2100	Saturn SL	44
2101	Sierra CE 5.7 V8	44
2102	Sierra Sport 5.0 V8	44
2103	Silverado	44
2104	Silverado 4.1	44
2105	Silverado 4.1 Diesel	44
2106	Silverado 4.2 Turbo Diesel	44
2107	Silverado Conquest 4.1 Diesel	44
2108	Silverado Conquest 4.2 Diesel Turbo	44
2109	Silverado D20/ Rodeio 4.2 TB Diesel	44
2110	Silverado DLX 4.1	44
2111	Silverado DLX 4.2 Conquest HD Diesel	44
2112	Silverado DLX 4.2 Diesel	44
2113	Silverado G. Blazer DLX/ Std 4.2 Dies.TB	44
2114	Silverado Grand Blazer DLX 4.1 mpfi	44
2115	Silverado High Country 5.3 V8 AWD Aut.	44
2116	Silverado Sport/ Fleet Side 5.7 CS	44
2117	Silverado Sport/Fleet Side 6.5 Dies. CS	44
2118	Silverado Trop. SL/ Van T.Diesel (todas)	44
2119	Silverado Tropical CD 4.1 Diesel	44
2120	Silverado Tropical CD 4.1 MPFI	44
2121	Silverado Tropical CD 4.2 Diesel	44
2122	SONIC HB LT 1.6 16V FlexPower 5p Aut.	44
2123	SONIC HB LT 1.6 16V FlexPower 5p Mec.	44
2124	SONIC HB LTZ 1.6 16V FlexPower 5p Aut.	44
2125	SONIC HB LTZ 1.6 16V FlexPower 5p Mec.	44
2126	SONIC HB LTZ EFFECT 1.6 16V FlexP 5p Aut	44
2127	SONIC Sed. LT 1.6 16V FlexPower 4p Aut.	44
2128	SONIC Sed. LT 1.6 16V FlexPower 4p Mec.	44
2129	SONIC Sed. LTZ 1.6 16V FlexPower 4p Aut.	44
2130	SONIC Sed. LTZ 1.6 16V FlexPower 4p Mec.	44
2131	Sonoma CE 4.3 V6	44
2132	SpaceVan Furgão 2.1 Diesel	44
2133	SpaceVan Furgão 2.2	44
2134	SpaceVan Passageiro 2.1Diesel	44
2135	SpaceVan Passageiro 2.2	44
2136	SPARK EUV ACTIV	44
2137	SPIN 1.8 8V Econo.Flex 5p Aut.	44
2138	SPIN ACTIV 1.8 8V Econo. Flex 5p Aut.	44
2139	SPIN ACTIV 1.8 8V Econo. Flex 5p Mec.	44
2140	SPIN ACTIV7 1.8 8V Econo.Flex 5p Aut.	44
2141	SPIN ADVANTAGE 1.8 8V Econo.Flex 5p Aut.	44
2142	SPIN ADVANTAGE 1.8 8V Econo.Flex 5p Mec.	44
2143	SPIN LS 1.8 8V Econo.Flex 5p Aut.	44
2144	SPIN LS 1.8 8V Econo.Flex 5p Mec.	44
2145	SPIN LT 1.8 8V Econo.Flex 5p Aut.	44
2146	SPIN LT 1.8 8V Econo.Flex 5p Mec.	44
2147	SPIN LTZ 1.8 8V Econo.Flex 5p Aut.	44
2148	SPIN LTZ 1.8 8V Econo.Flex 5p Mec.	44
2149	SPIN PREMIER 1.8 8V Econo.Flex 5p Aut.	44
2150	SPIN PREMIER 1.8 8V Econo.Flex 5p Mec.	44
2151	SS10 Pick-Up 4.3 V6	44
2152	Suburban 5.7/6.5 V8/5.3 V8	44
2153	Suprema CD 4.1 / 3.0	44
2154	Suprema Diamond	44
2155	Suprema GL 2.0	44
2156	Suprema GLS 2.2 / 2.0	44
2157	Suprema GLS 4.1	44
2158	Syclone 5.7 V8	44
2159	Tigra 1.6 16V	44
2160	Tigra Power Tech Coupe 1.6 SFI	44
2161	TRACKER 1.0 Turbo 12V Flex Aut. 	44
2162	TRACKER 1.0 Turbo 12V Flex Mec.	44
2163	TRACKER 1.2 Turbo 12V Flex Aut.	44
2164	TRACKER 100 Anos 1.2 Turbo 12V Aut. 	44
2165	TRACKER 2.0 16v 128cv MPFI 4x4 5p	44
2166	TRACKER 2.0 TB Int. Diesel 4x4 4p	44
2167	TRACKER Freeride 1.8 16V Flex 4x2 Mec.	44
2168	TRACKER LT 1.0 Turbo 12V Flex Aut.	44
2169	TRACKER LT 1.4 Turbo 16V Flex 4x2 Aut.	44
2170	TRACKER LT 1.8 16V Flex 4x2 Aut.	44
2171	TRACKER LTZ 1.0 Turbo 12V Flex Aut.	44
2172	TRACKER LTZ 1.2 Turbo 12V Flex Aut.	44
2173	TRACKER LTZ 1.4 Turbo 16V Flex 4x2 Aut.	44
2174	TRACKER LTZ 1.8 16V Flex 4x2 Aut.	44
2175	TRACKER Midnight 1.0 Turbo 12V Flex Aut.	44
2176	TRACKER Midnight 1.4 Turbo Flex Aut.	44
2177	TRACKER Premier 1.0 Turbo 12V Flex Aut.	44
2178	TRACKER Premier 1.2 Turbo 12V Flex Aut.	44
2179	TRACKER Premier 1.4 Turbo 16V Flex Aut	44
2180	TRACKER RS 1.2 Turbo 12V Flex Aut.	44
2181	Trafic Chassi Longo Diesel	44
2182	Trafic Furgão Carga 2.1 Diesel	44
2183	Trafic Furgao Carga 2.2	44
2184	Trafic Passageiros 2.1 Diesel	44
2185	Trafic Passageiros 2.2	44
2186	TRAILBLAZER High Country 2.8 TB Die Aut.	44
2187	TRAILBLAZER LTZ 2.8 CTDI Diesel Aut.	44
2188	TRAILBLAZER LTZ 3.6 V6  Aut.	44
2189	TRAILBLAZER PREMIER 2.8 TB Diesel Aut.	44
2190	TRAILBLAZER PREMIER 3.6 V6 Aut.	44
2191	Vectra CD 2.0 (modelo antigo)	44
2192	Vectra CD 2.2 16V / 2.0 16V Mec./Aut.	44
2193	Vectra COLLECTION 2.0 FlexPower 8V Aut.	44
2194	Vectra Comfort 2.0 MPFI	44
2195	Vectra Elegan. 2.0 MPFI 8V FlexPower Aut	44
2196	Vectra Elegan. 2.0 MPFI 8V FlexPower Mec	44
2197	Vectra Elegance 2.0 MPFI	44
2198	Vectra Elegance 2.2 MPFI 16V Aut.	44
2199	Vectra Elite 2.0 MPFI	44
2200	Vectra Elite 2.0 MPFI 8V FlexPower Aut.	44
2201	Vectra Elite 2.2 MPFI 16V Aut.	44
2202	Vectra Elite 2.4 MPFI 16V FlexPower Aut.	44
2203	Vectra Expres./ Collection  2.0 MPFI 8V	44
2204	Vectra EXPRESSION 2.0 MPFI FlexPower Aut	44
2205	Vectra EXPRESSION 2.0 MPFI FlexPower Mec	44
2206	Vectra GL 2.2 / 2.0 MPFI	44
2207	Vectra GL 2.2 MPFI Milenium	44
2208	Vectra GLS/ Challenge 2.2 MPFI 16V	44
2209	Vectra GLS/Expres.2.2/ 2.0 e 2.0 CD 8V	44
2210	Vectra GSi 2.0 16V (modelo antigo)	44
2211	Vectra GT 2.0 MPFI 8V FlexPower Aut.	44
2212	Vectra GT 2.0 MPFI 8V FlexPower Mec.	44
2213	Vectra GT-X 2.0 MPFI 8V FlexPower Aut.	44
2214	Vectra GT-X 2.0 MPFI 8V FlexPower Mec.	44
2215	Veraneio S / Luxe 4.1	44
2216	Veraneio S/ Luxe 4.0 Dies./TB Dies.	44
2217	Zafira 2.0/ CD 2.0  8V  MPFI 5p Mec.	44
2218	Zafira 2.0/ CD 2.0 16V  MPFI 5p	44
2219	Zafira 2.0/ CD 2.0 8V MPFI 5p Aut.	44
2220	Zafira COLLECTION 2.0 FlexPower 8V Aut.	44
2221	Zafira Comfort 2.0 MPFI FlexPower 8V 5p	44
2222	Zafira Eleg.2.0 MPFI FlexPower 8V 5p Aut	44
2223	Zafira Elegance 2.0 MPFI 16v 136cv 5p	44
2224	Zafira Elegance 2.0 MPFI FlexPower 8V 5p	44
2225	Zafira Elite 2.0 MPFI 16v 136cv 5p	44
2226	Zafira Elite 2.0 MPFI FlexPower 8V  Aut	44
2227	Zafira Elite 2.0 MPFI FlexPower 8V 5p	44
2228	Zafira Expres. 2.0 MPFI FlexPower 5p Aut	44
2229	Accent GLS 1.5 12V/16V Aut.	51
2230	Accent GLS 1.5 12V/16V Mec.	51
2231	Accent GS 3p Mec.	51
2232	Accent L/ LR 1.5 2/4p	51
2233	Accent LS 4p	51
2234	Atos Prime GL 1.0 Mec.	51
2235	Atos Prime GLS 1.0 Aut.	51
2236	Atos Prime GLS 1.0 Mec.	51
2237	Atos Prime GLS 1.0 Semi-Aut.	51
2238	AZERA 3.0 V6 24V 4p Aut.	51
2239	AZERA GLS 3.3 V6 24V 4p Aut.	51
2240	Coupe FX 2.0 Aut.	51
2241	Coupe FX 2.0 Mec.	51
2242	Coupe FX 2.7 V6 24V 180cv Aut.	51
2243	Coupe FX 2.7 V6 24V 180cv Mec.	51
2244	Creta 1 Million 1.6 16V Flex Aut.	51
2245	Creta Action 1.6 16V Flex Aut.	51
2246	Creta Attitude 1.6 16V Flex Aut.	51
2247	Creta Attitude 1.6 16V Flex Mec.	51
2248	Creta Attitude Plus 1.6 16V Flex Aut.	51
2249	Creta Comfort 1.0 TB 12V Flex Aut.	51
2250	Creta Comfort Plus 1.0 TB 12V Flex Aut.	51
2251	Creta Comfort Safety 1.0 TB 12V Aut.	51
2252	Creta Launch Edition 1.6 16V Flex Aut.	51
2253	Creta Limit. Safety 1.0 TB 12V Flex Aut.	51
2254	Creta Limited 1.0 TB 12V Flex Aut.	51
2255	Creta Limited Edition 1.6 16V Flex Aut.	51
2256	Creta N Line 1.0 TB 12V Flex Aut.	51
2257	Creta N Line 1.6 TB 12V Flex Aut.	51
2258	Creta N Line Night Ed. 2.0 16V Flex Aut.	51
2259	Creta Plat. Safety 1.0 TB 12V Flex Aut.	51
2260	Creta Platinum 1.0 TB 12V Flex Aut.	51
2261	Creta Prestige 2.0 16V Flex Aut.	51
2262	Creta Pulse 1.6 16V Flex Aut.	51
2263	Creta Pulse 1.6 16V Flex Mec.	51
2264	Creta Pulse 2.0 16V Flex Aut.	51
2265	Creta Pulse Plus 1.6 16V Flex Aut.	51
2266	Creta Smart 1.6 16V Flex Aut.	51
2267	Creta Smart Plus 1.6 16V Flex Aut.	51
2268	Creta Sport 2.0 16V Flex Aut.	51
2269	Creta Ultimate 1.6 TB 16V Aut.	51
2270	Creta Ultimate 2.0 16V Flex Aut.	51
2271	Cupê 2.0	51
2272	Elantra 2.0 16V Flex Aut.	51
2273	Elantra GL	51
2274	Elantra GLS 1.6	51
2275	Elantra GLS 1.8 16V	51
2276	Elantra GLS 1.8 16V Aut.	51
2277	Elantra GLS 1.8 16V Mec.	51
2278	Elantra GLS 2.0 16V Aut.	51
2279	Elantra GLS 2.0 16V Flex Aut.	51
2280	Elantra GLS 2.0 16V Mec.	51
2281	Elantra Special Edit. 2.0 16V Flex Aut.	51
2282	Elantra Wagon 1.8 16V	51
2283	EQUUS 4.6 V8 32V 366cv 4p Aut.	51
2284	Excel GLS	51
2285	Excel GS	51
2286	Excel L	51
2287	Excel LS/ GL	51
2288	Galloper 2.5 Luxo Turbo Diesel	51
2289	Galloper 2.5 Super Luxo Turbo Diesel	51
2290	Galloper 3.0 V6 Luxo	51
2291	Galloper 3.0 V6 Super Luxo Aut	51
2292	Galloper 3.0 V6 Super Luxo Mec	51
2293	GENESIS 3.8 V6 24V 290cv 4p Aut.	51
2294	Grand Santa Fé  3.3 V6 4X4 Tiptronic	51
2295	H1 Starex HSV 2.4 16V 137cv  Aut.	51
2296	H1 Starex HSV 2.5 Diesel	51
2297	H1 Starex SVX 2.4 16V	51
2298	H1 Starex SVX 2.5 TDI 100cv Diesel	51
2299	H1 Starex SVX 2.6 85cv Diesel	51
2300	H100 DLX Furgão Diesel	51
2301	H100 DLX/ Panel Diesel	51
2302	H100 GL Diesel	51
2303	H100 GL Furgão Extra-Longo Diesel	51
2304	H100 GLS Diesel	51
2305	H100 GS (12 lugares)	51
2306	H100 GS Diesel (12 lugares)	51
2307	H100 Porter Truck Diesel	51
2308	H100 SPR Diesel (15 lugares)	51
2309	H100 Top Diesel	51
2310	HB20 1 Million 1.6 Flex 16V Aut.	51
2311	HB20 5 Anos 1.0 Flex 12V Mec.	51
2312	HB20 5 Anos 1.6 Flex 16V Aut.	51
2313	HB20 C./C.Plus/C.Style 1.6 Flex 16V Mec.	51
2314	HB20 C.Style/C.Plus 1.6 Flex 16V Aut.	51
2315	HB20 Comf. Plus Tech 1.0 TB Flex 12V Aut	51
2316	HB20 Comf./C.Plus/C.Style 1.0 Flex 12V	51
2317	HB20 Comfort 1.0 Flex 12V Mec.	51
2318	HB20 Comfort 1.0 TB Flex 12V Aut	51
2319	HB20 Comfort 1.0 TB Flex 12V Mec	51
2320	HB20 Comfort Plus 1.0 Flex 12V Mec.	51
2321	HB20 Comfort Plus 1.0 TB Flex 12V Aut.	51
2322	HB20 Comfort Plus 1.0 TB Flex 12V Mec.	51
2323	HB20 Comfort Style 1.0 TB Flex 12V Mec.	51
2324	HB20 Copa do Mundo 1.0 Flex 12V Mec.	51
2325	HB20 Copa do Mundo 1.6 Flex 16V Aut.	51
2326	HB20 Copa do Mundo 1.6 Flex 16V Mec.	51
2327	HB20 Copa Mundo Qatar 1.0 Flex Mec	51
2328	HB20 Copa Mundo Qatar 1.0 TB Flex Aut.	51
2329	HB20 Diamond 1.0 TB Flex 12V Aut.	51
2330	HB20 Diamond Plus 1.0 TB Flex 12V Aut.	51
2331	HB20 Edição Especial 1.0 Flex Mec.	51
2332	HB20 Edição Especial 1.0 TB Flex Aut.	51
2333	HB20 Evol. Bluelink 1.0 TB Flex 12V Aut.	51
2334	HB20 Evolution 1.0 Flex 12V Mec.	51
2335	HB20 Evolution 1.0 TB Flex 12V Aut.	51
2336	HB20 Evolution Bluelink 1.0 Flex 12V Mec	51
2337	HB20 For You 1.0 Flex 12V 5p	51
2338	HB20 Launch Edition 1.6 Flex 16V Aut.	51
2339	HB20 Limited 1.0 Flex 12V Mec.	51
2340	HB20 Limited 1.0 TB Flex 12V Aut.	51
2341	HB20 Limited Plus 1.0 Flex 12V Mec.	51
2342	HB20 Ocean 1.0 Flex 12V 5p Mec.	51
2343	HB20 Ocean 1.6 Flex 16V 5p Aut.	51
2344	HB20 Ocean 1.6 Flex 16V 5p Mec.	51
2345	HB20 Plat. Safety 1.0 TB Flex 12V Aut.	51
2346	HB20 Platinum 1.0 TB Flex 12V Aut.	51
2347	HB20 Platinum 1.0 TB Flex 12V Mec.	51
2348	HB20 Platinum Plus 1.0 TB Flex 12V Aut.	51
2349	HB20 Premium 1.6 Flex 16V Aut.	51
2350	HB20 Premium 1.6 Flex 16V Mec.	51
2351	HB20 R spec 1.6 Flex 16V Aut.	51
2352	HB20 R spec 1.6 Flex 16V Mec.	51
2353	HB20 R spec Limited 1.6 flex 16V Aut.	51
2354	HB20 Sense 1.0 Flex 12V Mec.	51
2355	HB20 Sense 1.0 Turbo Flex 12V Aut.	51
2356	HB20 Sense Plus 1.0 Flex 12V Mec.	51
2357	HB20 Spicy 1.0 Flex 12V Mec.	51
2358	HB20 Spicy 1.6 Flex 16V Aut.	51
2359	HB20 Spicy 1.6 Flex 16V Mec.	51
2360	HB20 Sport 1.0 TB Flex 12V Aut.	51
2361	HB20 Unique 1.0 Flex 12V Mec.	51
2362	HB20 Vision 1.0 Flex 12V Mec.	51
2363	HB20 Vision 1.0 TB Flex 12V Aut.	51
2364	HB20 Vision 1.6 Flex 16V Aut	51
2365	HB20 Vision 1.6 Flex 16V Mec.	51
2366	HB20 Vision Bluelink 1.6 Flex 16V Aut.	51
2367	HB20 Vision Bluelink 1.6 Flex 16V Mec.	51
2368	HB20S  Impress 1.6 Flex 16V Aut.	51
2369	HB20S  Impress 1.6 Flex 16v Mec.	51
2370	HB20S 1 Million 1.6 Flex 16V Aut. 4p	51
2371	HB20S 5 Anos 1.0 Flex 12V Mec.	51
2372	HB20S 5 Anos 1.6 Flex 16V Aut.	51
2373	HB20S C.Plus/C.Style 1.6 Flex 16V Mec.4p	51
2374	HB20S C.Plus/C.Style1.0 Flex 12V Mec. 4P	51
2375	HB20S C.Style/C.Plus1.6 Flex 16V Aut. 4p	51
2376	HB20S Com. Plus Tech 1.0 TB Flex 12V Aut	51
2377	HB20S Comfort 1.0  Flex 12V Mec.	51
2378	HB20S Comfort 1.0 TB Flex 12V Aut.	51
2379	HB20S Comfort Plus 1.0 Flex 12V Mec.	51
2380	HB20S Comfort Plus 1.0 TB Flex 12V Aut	51
2381	HB20S Comfort Plus 1.0 TB Flex 12V Mec.	51
2382	HB20S Comfort Style 1.0 TB Flex 12V Mec.	51
2383	HB20S Copa do Mundo 1.0 Flex 12V Mec.	51
2384	HB20S Copa do Mundo 1.6 Flex 16V Aut.	51
2385	HB20S Copa do Mundo 1.6 Flex 16V Mec.	51
2386	HB20S Copa Mundo Qatar 1.0 Flex Mec.	51
2387	HB20S Copa Mundo Qatar 1.0 TB Flex Aut.	51
2388	HB20S Diamond 1.0 TB Flex 12V Aut.	51
2389	HB20S Diamond Plus 1.0 TB Flex 12V Aut.	51
2390	HB20S Edição Especial 1.0 Flex Mec.	51
2391	HB20S Edição Especial 1.0 TB Flex Aut.	51
2392	HB20S Evol. Bluelink 1.0 Flex 12 Mec.	51
2393	HB20S Evol. Bluelink 1.0 TB Flex 12V Aut	51
2394	HB20S Evolution 1.0 Flex 12V Mec.	51
2395	HB20S Evolution 1.0 TB Flex 12V Aut.	51
2396	HB20S For You 1.0 Flex 12V 4p	51
2397	HB20S Limited 1.0  Flex 12V Mec.	51
2398	HB20S Limited 1.0  TB Flex 12V Aut.	51
2399	HB20S Limited Plus 1.0  Flex 12V Mec.	51
2400	HB20S Ocean 1.6 Flex 16v 4p Aut.	51
2401	HB20S Ocean 1.6 Flex 16V 4p Mec.	51
2402	HB20S Plat. Safety 1.0 TB Flex 12V Aut.	51
2403	HB20S Platinum 1.0 TB Flex 12V Aut.	51
2404	HB20S Platinum 1.0 TB Flex 12V Mec.	51
2405	HB20S Platinum Plus 1.0 TB Flex 12V Aut.	51
2406	HB20S Premium 1.6 Flex 16V Aut. 4p	51
2407	HB20S Premium 1.6 Flex 16V Mec. 4p	51
2408	HB20S Style 1.6 Flex 16V Aut.	51
2409	HB20S Unique 1.0 Flex 12V Mec.	51
2410	HB20S Vision 1.0 Flex 12V Mec.	51
2411	HB20S Vision 1.0 TB Flex 12V Aut.	51
2412	HB20S Vision 1.6 Flex 16V Aut.	51
2413	HB20S Vision 1.6 Flex 16V Mec.	51
2414	HB20S Vision Bluelink 1.6 Flex 16V Aut.	51
2415	HB20S Vision Bluelink 1.6 Flex 16V Mec.	51
2416	HB20X Diamond 1.6 Flex 16V Aut.	51
2417	HB20X Diamond Plus 1.6 Flex 16V Aut.	51
2418	HB20X Evol. Bluelink 1.6 Flex 16V Aut.	51
2419	HB20X Evolution 1.6 Flex 16V Aut.	51
2420	HB20X Premium 1.6 Flex 16V Aut.	51
2421	HB20X Premium 1.6 Flex 16V Mec.	51
2422	HB20X Style 1.6 Flex 16V Aut.	51
2423	HB20X Style 1.6 Flex 16v Mec.	51
2424	HB20X Vision 1.6 Flex 16V Aut.	51
2425	HB20X Vision 1.6 Flex 16V Mec.	51
2426	HR 2.5 4WD Diesel 	51
2427	HR 2.5 TCI Diesel (RS/RD)	51
2428	i30 1.6 16V Flex 5p Aut.	51
2429	i30 1.8 16V Aut. 5p	51
2430	i30 2.0 16V 145cv 5p Aut.	51
2431	i30 2.0 16V 145cv 5p Mec.	51
2432	i30 Serie Limitada 1.8 16V Aut. 5p	51
2433	i30cw 2.0 16V 145cv Aut. 5p	51
2434	i30cw 2.0 16V 145cv Mec. 5p	51
2435	IONIQ 1.6 16V Aut. (Híbrido)	51
2436	IONIQ 5 SIGNATURE (Elétrico)	51
2437	ix35 2.0 16V 170cv 2WD/4WD Aut.	51
2438	ix35 2.0 16V 170cv 2WD/4WD Mec.	51
2439	ix35 2.0 16V 2WD Flex Aut.	51
2440	ix35 2.0 16V 2WD Flex Mec.	51
2441	ix35 2.0 Launching Edition 16V Flex Aut.	51
2442	ix35 GL 2.0 16V 2WD Flex Aut.	51
2443	ix35 GLS 2.0 16V 2WD Flex Aut.	51
2444	KONA 1.6 16V Aut. (Hibrido)	51
2445	KONA EV (Elétrico)	51
2446	KONA Signature GDI 1.6 16V Aut (Hibrido)	51
2447	KONA Ultimate GDI 1.6 16V Aut. (Hibrido)	51
2448	Matrix GLS 1.8 16V 123cv Aut.	51
2449	Matrix GLS 1.8 16V 123cv Mec.	51
2450	PALISADE Signature 3.8 GDI AWD Aut.	51
2451	Porter GL 4x2 Curto/Longo Diesel	51
2452	Porter GLS CD 4x2 2.6 8V Diesel	51
2453	Santa Fe 3.5 V6 4X4 Aut.	51
2454	Santa Fe GLS 2.4 Tiptronic	51
2455	Santa Fe GLS 2.7 V6 4x4TipTronic	51
2456	Santa Fe GLS 3.5 V6 4x4 Tiptronic	51
2457	Santa Fe/GLS 3.3 V6 4X4 Tiptronic	51
2458	Scoupe	51
2459	Sonata 2.4 16V 182cv 4p Aut.	51
2460	Sonata GL 2.0 4p	51
2461	Sonata GLS 2.0 4p	51
2462	Sonata GLS 2.5 Aut.	51
2463	Sonata GLS 2.7 V6 24V 179cv 4p Aut.	51
2464	Sonata GLS 3.0 4p Aut.	51
2465	Sonata GLS 3.3 V6 24V 235cv 4p Aut.	51
2466	Terracan 2.5 8V 100cv TB Diesel Aut.	51
2467	Terracan 2.5 8V 100cv TB Diesel Mec.	51
2468	Terracan 2.9 CRDI 8V 163cv Diesel Aut.	51
2469	Trajet GLS 2.7 V6 24v 179cv Aut.	51
2470	Tucson 2.0 16V Aut.	51
2471	Tucson 2.0 16V Flex Aut.	51
2472	Tucson 2.0 16V Flex Mec.	51
2473	Tucson 2.0 16V Mec.	51
2474	Tucson 2.0 CRDi 16V 112cv Diesel Aut.	51
2475	Tucson 2.7 MPFI 24V 175cv Aut.	51
2476	Tucson Ed. Especial 1.6 Turbo 16V Aut.	51
2477	Tucson GL 1.6 Turbo 16V Aut.	51
2478	Tucson GLS 1.6 Turbo 16V Aut.	51
2479	Tucson Limited 1.6 Turbo 16V Aut.	51
2480	Veloster 1.6 16V  140cv Aut.	51
2481	VERACRUZ GLS 3.8 4WD Aut.	51
2482	Cherokee Country 4.0 V6 4x4	57
2483	Cherokee Limited 3.2 4x4 V6 Aut.	57
2484	Cherokee Limited 3.7 4x4 V6 12V Aut.	57
2485	Cherokee Longitude 3.2 4x4 V6 Aut.	57
2486	Cherokee Rubicon 4.0 V6 4x4	57
2487	Cherokee Sport  4.0 Mec./Aut.	57
2488	Cherokee Sport 2.5 4x4 Diesel	57
2489	Cherokee Sport 3.7 4x4 V6 12V Aut.	57
2490	Cherokee Trailhawk 3.2 4x4 V6 Aut.	57
2491	Commander Black Hurricane 2.0 4x4 TB Aut	57
2492	Commander Limited 5.7 326cv 5p	57
2493	Commander Limited T270 1.3 TB Flex Aut.	57
2494	Commander Limited TD380 2.0 4x4 Die.Aut.	57
2495	Commander Longitude T270 1.3 TB Flex Aut	57
2496	Commander Overl. 2.2 TD 4x4 Diesel Aut.	57
2497	Commander Overl. TD380 2.0 4x4 Die. Aut.	57
2498	Commander Overland Hurric 2.0 4x4 TB Aut	57
2499	Commander Overland T270 1.3 TB Flex Aut.	57
2500	COMPASS Black Hurricane 2.0 4x4 TB Aut.	57
2501	COMPASS LIMITED 2.0 4x2 Flex 16V Aut.	57
2502	COMPASS LIMITED 2.0 4x4 Diesel 16V Aut.	57
2503	COMPASS LIMITED T270 1.3 TB 4x2 Flex Aut	57
2504	COMPASS LIMITED TD 350 2.0 4x4 Die. Aut.	57
2505	COMPASS Lon Nig. Eagle 1.3 4x2 Flex Aut.	57
2506	COMPASS LONG. T270 1.3 TB 4x2 Flex Aut.	57
2507	COMPASS LONG. TD 350 2.0 4x4 Diesel Aut.	57
2508	COMPASS LONGITUDE 2.0 4x2 Flex 16V Aut.	57
2509	COMPASS LONGITUDE 2.0 4x4 Dies. 16V Aut.	57
2510	COMPASS Night Eagle 2.0 4x2 Flex 16V Aut	57
2511	COMPASS Night Eagle 2.0 4x4 TB Dies. Aut	57
2512	COMPASS Over. Hurric 2.0 4x4 TB 16V Aut.	57
2513	COMPASS S 1.3 TB 4XE Aut. (Híbrido)	57
2514	COMPASS S 2.0 4x4 TB 16V Diesel Aut.	57
2515	COMPASS S T270 1.3 TB 4x2 Flex Aut.	57
2516	COMPASS SPORT 2.0 16V 156cv 5p	57
2517	COMPASS SPORT 2.0 4x2 Flex 16V Aut.	57
2518	COMPASS SPORT 2.0 4x4 flex 16V Aut.	57
2519	COMPASS SPORT T270 1.3 TB 4x2 Flex Aut.	57
2520	COMPASS T270 80 Anos 1.3 TB 4x2 Flex Aut	57
2521	COMPASS TD 350 80 Anos 2.0 4x4 Die. Aut.	57
2522	COMPASS TRAILHAWK 2.0 4x4 Dies. 16V Aut.	57
2523	COMPASS TRAILHAWK TD350 2.0 4x4 Die. Aut	57
2524	Gladiator Rubicon 3.6 V6 284 cv	57
2525	Grand Cherokee 4XE 2.0 T. Aut. (Híbrido)	57
2526	Grand Cherokee 80 Anos 3.0 TB Dies.Aut. 	57
2527	Grand Cherokee Laredo 2.7 I-5 TB Dies.	57
2528	Grand Cherokee Laredo 3.1 TB Diesel Aut	57
2529	Grand Cherokee Laredo 3.6 4x4 V6 Aut.	57
2530	Grand Cherokee Laredo 4.0 Aut.	57
2531	Grand Cherokee Lim. 75 anos 3.6 4x4 Aut.	57
2532	Grand Cherokee Limit.4.7 Quad.Drive Aut.	57
2533	Grand Cherokee Limited 3.0 TB Dies. Aut	57
2534	Grand Cherokee Limited 3.6 4x4 V6 Aut.	57
2535	Grand Cherokee Limited 4.7 Aut.	57
2536	Grand Cherokee Limited 5.2 Aut.	57
2537	Grand Cherokee Limited 5.7 326cv	57
2538	Grand Cherokee Limited LX 5.9	57
2539	Grand Cherokee Nova Limited 4.7	57
2540	Grand Cherokee Overland 5.7 326cv	57
2541	Grand Cherokee SRT8 6.1 V8 16V 432cv Aut	57
2542	Renegade 1.8 4x2 Flex 16V Aut.	57
2543	Renegade 1.8 4x2 Flex 16V Mec.	57
2544	Renegade 75 Anos 1.8 4X2 Flex 16V Aut.	57
2545	Renegade 75 Anos 2.0 4X4 TB Diesel Aut.	57
2546	Renegade Altitude T270 1.3 TB Flex Aut.	57
2547	Renegade Custom 1.8 4x2 Flex 16V Mec.	57
2548	Renegade Custom 2.0 4x4 TB Diesel Aut.	57
2549	Renegade Lim. Edit. 1.8 4x2 Flex 16V Aut	57
2550	Renegade Limited 1.8 4x2 Flex 16V Aut.	57
2551	Renegade Limited 2.0 4x4 TB Diesel Aut.	57
2552	Renegade Lo. Night Eagle 1.3 TB Flex Aut	57
2553	Renegade Long. T270 1.3 TB 4x2 Flex Aut.	57
2554	Renegade Longitude 1.8 4x2 Flex 16V Aut.	57
2555	Renegade Longitude 2.0 4x4 TB Diesel Aut	57
2556	Renegade Moab 2.0 4x4 TB Diesel Aut.	57
2557	Renegade Night Eagle 1.8 4x2  Flex Aut.	57
2558	Renegade Night Eagle 2.0 4x4 TB Die. Aut	57
2559	Renegade S T270 1.3 TB 4x4 Flex Aut.	57
2560	Renegade SAHARA T270 1.3 TB 4x2 Flex Aut	57
2561	Renegade Sport 1.8 4x2 Flex 16V Aut.	57
2562	Renegade Sport 1.8 4x2 Flex 16V Mec.	57
2563	Renegade Sport 2.0 4x4 TB Diesel Aut.	57
2564	Renegade Sport Altitude 1.3 TB Flex Aut.	57
2565	Renegade Sport T270 1.3 TB 4x2 Flex Aut.	57
2566	Renegade STD 1.8 4x2 Flex 16v Aut.	57
2567	Renegade T270 1.3 TB 4x2 Flex Aut.	57
2568	Renegade Trailhawk 2.0 4x4 TB Diesel Aut	57
2569	Renegade Trailhawk T270 1.3 TB Flex Aut.	57
2570	Renegade Willys 2.0 4x4 TB Diesel Aut.	57
2571	Renegade Willys T270 1.3 TB 4x4 Flex Aut	57
2572	Wrangler 4.0/Sport 4.0	57
2573	Wrangler RUBICON 2.0 Turbo 4x4 4p Aut.	57
2574	Wrangler SAHARA 2.0 4x4 271cv 2p Aut.	57
2575	Wrangler SAHARA 3.8 V6 199cv 2p	57
2576	Wrangler SAHARA Overland 2.0 4x4 4p Aut.	57
2577	Wrangler Sport 3.6 V6 284cv 2p	57
2578	Wrangler Sport 3.8 V6 199cv	57
2579	Wrangler Unlimited 75 Anos 3.6 V6 284cv	57
2580	Wrangler Unlimited 80 Anos 2.0 TB 4p 	57
2581	Wrangler Unlimited SAHARA 2.0 TB 4p Aut	57
2582	Wrangler Unlimited SAHARA 3.6 V6 4p	57
2583	Wrangler Unlimited SAHARA 3.8 V6  4p	57
2584	Wrangler Unlimited Sport 3.6 V6 284cv 4p	57
2585	Wrangler Unlimited Sport 3.8 V6 199cv	57
2586	Besta EST 2.7 Diesel (10/12lug.)	61
2587	Besta EST Full 2.7 Diesel (10/12lug.)	61
2588	Besta Furgão 2.2 Diesel	61
2589	Besta Furgão 2.7 Diesel	61
2590	Besta Furgão Grand 3.0 Diesel	61
2591	Besta GS 2.7 8V 12L Diesel	61
2592	Besta GS Full 2.7 Diesel	61
2593	Besta GS Grand 3.0 8V 16L Diesel	61
2594	Besta ST 2.2 Diesel (12lug.)	61
2595	Bongo K-2400 2.4 Diesel	61
2596	Bongo K-2500 2.5 4x2 TB Diesel	61
2597	Bongo K-2500 2.5 4x4 TB Diesel	61
2598	Bongo K-2700 2.7 4x2/4x4 Diesel	61
2599	Bongo K-2700 2.7 4x4 Basculante Diesel	61
2600	Bongo K-2700 2.7 4x4 CD Diesel	61
2601	Bongo K-3500/K-3600/110 3.6 Diesel	61
2602	CADENZA EX 3.5 V6 24V Aut.	61
2603	Carens EX 2.0 16V  Aut.	61
2604	Carens LS 1.8 16V 130cv Aut.	61
2605	Carens LS 1.8 16V 130cv Mec.	61
2606	Carnival 2.5 V6	61
2607	Carnival EX 3.5 V6 24V 276/272cv Aut.	61
2608	Carnival EX 3.8 V6 24V 242cv Aut.	61
2609	Carnival GS 2.9 TDI 16V 125cv Diesel	61
2610	Cerato 1.6 16 V Flex Mec.	61
2611	Cerato 1.6 16V  Flex  Aut.	61
2612	Cerato 1.6 16V Aut.	61
2613	Cerato 1.6 16V Mec.	61
2614	Cerato 2.0 16V Aut.	61
2615	Cerato EX 2.0 16V Flex Aut.	61
2616	Cerato KOUP 2.0 16V Aut.	61
2617	Cerato SX 2.0 16V Flex Aut.	61
2618	Ceres Pick-Up 2.2 Diesel	61
2619	Clarus GLX 2.0 16V Aut.	61
2620	Clarus GLX 2.0 16V Mec	61
2621	Clarus Wagon GLX 2.0 16V Aut.	61
2622	Clarus Wagon GLX 2.0 16V Mec.	61
2623	EV5 Land (Elétrico)	61
2624	EV9 GTL (Elétrico)	61
2625	Grand Carnival EX 3.3 V6 24V 270cv Aut.	61
2626	Magentis EX 2.0 16V Aut.	61
2627	Magentis LX 2.0 16V Aut	61
2628	MOHAVE EX 3.0 V6 24V 256cv TB Dies. Aut.	61
2629	MOHAVE EX 3.8 V6 24V 275cv 4x4 Aut.	61
2630	MOHAVE EX 4.6 V8 32V 340cv 4x4 Aut.	61
2631	Niro EX 1.6 GDI  (Híbrido) 	61
2632	Niro SX Prestige 1.6 GDI (Híbrido)	61
2633	Niro SX Rio Limited Edt 1.6 GDI  (Híb.) 	61
2634	Opirus GL 3.5 V6 24V 202cv Aut.	61
2635	Opirus GL 3.8 V6 24V 267cv Aut.	61
2636	OPTIMA 2.0 16V 165cv Aut.	61
2637	OPTIMA 2.4 16V 180cv Aut.	61
2638	Picanto EX 1.1/1.0/ 1.0 Flex Aut.	61
2639	Picanto EX 1.1/1.0/ 1.0 Flex Mec.	61
2640	Picanto GT 1.0 12V Flex Aut.	61
2641	QUORIS EX 3.8 V6 24V 294cv Aut.	61
2642	RIO EX 1.6 Flex Aut.	61
2643	RIO LX 1.6 Flex Aut.	61
2644	Sephia GTX 1.5 16V	61
2645	Sephia GTX 1.6	61
2646	Sephia LS 1.5 16V Aut.	61
2647	Sephia LS 1.5 16V Mec.	61
2648	Sephia SLX	61
2649	Shuma LS 1.5 16V Aut.	61
2650	Shuma LS 1.5 16V Mec.	61
2651	Sorento 2.4 16V 4x2 Aut.	61
2652	Sorento 2.4 16V 4x4 Aut.	61
2653	Sorento 3.3 V6 24V 270cv 4x2 Aut.	61
2654	Sorento 3.5 V6 24V 4x2 Aut.	61
2655	Sorento 3.5 V6 24V 4x4 Aut.	61
2656	Sorento EX 2.2 16V 4x4 Aut. Diesel	61
2657	Sorento EX 2.5 140/170cv 4x4 Aut.Diesel	61
2658	Sorento EX 2.5 16V 4x4 Mec. Diesel	61
2659	Sorento EX 3.5 V6 24V 197cv 4x4 Aut.	61
2660	Sorento EX 3.8 V6 24V 267cv 4x4 Aut.	61
2661	Sorento LX 2.5 16V 140cv 4x4 Aut. Diesel	61
2662	Sorento LX 2.5 16V 140cv 4x4 Mec. Diesel	61
2663	SOUL 1.6/ 1.6 16V FLEX Aut.	61
2664	SOUL 1.6/ 1.6 16V FLEX Mec.	61
2665	Sportage 2.0 16V Aut.	61
2666	Sportage 2.0 8V TB-IC Diesel	61
2667	Sportage DLX 2.0 16V Aut.	61
2668	Sportage DLX 2.0 16V Mec.	61
2669	Sportage DLX 2.2 Diesel Mec	61
2670	Sportage EX 1.6 T-GDI (Híbrido)	61
2671	Sportage EX 2.0 16V Mec.	61
2672	Sportage EX 2.0 16V/ 2.0 16V Flex Aut.	61
2673	Sportage EX 2.7 V6 4x4 Aut.	61
2674	Sportage EX Prestige 1.6 T-GDI (Híbrido)	61
2675	Sportage Grand 2.0 16V Aut.	61
2676	Sportage Grand 2.0 16V Mec.	61
2677	Sportage Grand 2.0 8V TB-IC Diesel	61
2678	Sportage GTE 2.2 4x4 Diesel	61
2679	Sportage LX 2.0 16V 142cv 5p	61
2680	Sportage LX 2.0 16V/ 2.0 16V Flex  Aut.	61
2681	Sportage LX 2.0 16V/ 2.0 16V Flex Mec.	61
2682	Sportage Targa 2.0 16V	61
2683	Stinger GT 3.3 V6 Bi-Turbo 370cv Aut.	61
2684	STONIC SX 1.0 TB Aut. (Híbrido)	61
2685	Def. 90 X-DY D350 HSE Die. Aut.( Híb.)	64
2686	Defe. 110 X-DY HSE P400e Aut. (Hib.)	64
2687	Defe. 110 X-DY SE D300 Die Aut. (Hib.)	64
2688	Defe. 110 X-DY.HSE D300 Die Aut. (Híb.)	64
2689	Defe. 110 X-DY.HSE D350 Die Aut. (Híb.)	64
2690	Defe. 130 Outbound D300 Die. Aut. (Hib.)	64
2691	Defe. 130 X-DY S 3.0 I6 Die.Aut.(Hib.)	64
2692	Defender 110 2.0 Turbo HSE Si4 Aut.	64
2693	Defender 110 2.0 Turbo S Si4 Aut.	64
2694	Defender 110 2.0 Turbo SE Si4 Aut.	64
2695	Defender 110 2.4 122cv T.Diesel	64
2696	Defender 110 2.5 HCPU TDi CS Diesel	64
2697	Defender 110 2.5 TDi County Pers. Diesel	64
2698	Defender 110 2.5 TDi Hard Top Diesel	64
2699	Defender 110 2.5 TDi High Capacity Dies.	64
2700	Defender 110 2.5 TDi Personel Diesel	64
2701	Defender 110 75th 3.0 Diesel Aut. (Hib.)	64
2702	Defender 110 HSE D300 Die. Aut.(Híb.)	64
2703	Defender 110 LE FIRE & ICE 2.4 T. Diesel	64
2704	Defender 110 RAW 2.4 122cv T. Diesel	64
2705	Defender 110 SVX Lim.Edit. 2.4 T.Diesel	64
2706	Defender 110 TD5 2.5 4x4 Diesel	64
2707	Defender 110 TDI County SW Diesel	64
2708	Defender 110 TDI SW Diesel	64
2709	Defender 110 TROPHY Edition 3.0 D350 4X4 Aut.	64
2710	Defender 110 X D300  Die. Aut. (Híb.)	64
2711	Defender 110 X D350  Die. Aut. (Híb.)	64
2712	Defender 110 X P400e Aut. (Hibrido)	64
2713	Defender 110 X-DY S D300 Die Aut. (Hib.)	64
2714	Defender 130 Chassis CD Diesel	64
2715	Defender 130 High CAP Diesel	64
2716	Defender 130 TDI CD Diesel	64
3154	2008 GT 1.0 Turbo 200 5p Aut.	84
2717	Defender 130 X 3.0 I6 D350.Aut.(Hibrido)	64
2718	Defender 130 X 3.0 I6 Die.Aut.(Hibrido)	64
2719	Defender 90 2.0 Turbo SE Si4 Aut.	64
2720	Defender 90 2.4 122cv T.Diesel	64
2721	Defender 90 2.5 TDi CS Diesel	64
2722	Defender 90 D300 HSE Diesel Aut.( Hibr.)	64
2723	Defender 90 D300 S Diesel Aut. (Hibrido)	64
2724	Defender 90 LE FIRE & ICE 2.4 T. Diesel	64
2725	Defender 90 RAW 2.4 122cv T.Diesel	64
2726	Defender 90 Soft Top Diesel	64
2727	Defender 90 SVX Lim.Edit. 2.4 T.Diesel	64
2728	Defender 90 TDI CSW Diesel	64
2729	Defender 90 TDI Hard Top Diesel	64
2730	Defender 90 TDI SW Diesel	64
2731	Disc. Sp. S 2.0 4x4 Dies. Aut. (Híb.)	64
2732	Disc. Sp. SE Dyn 2.0 D200 Die.Aut.(Híb.)	64
2733	Discov. Metrop. Edt. 3.0 4x4 Die. (Híb.)	64
2734	Discov. Sp. HSE 2.0 TB 240cv Die. Aut	64
2735	Discovery Dyn HSE 3.0 4x4 Die. (Hib.)	64
2736	Discovery ES 3.9 V8	64
2737	Discovery ES 4.0 V8 Aut.	64
2738	Discovery ES TD5 2.5 4x4 4p Diesel Aut.	64
2739	Discovery ES TD5 2.5 4x4 4p Diesel Mec.	64
2740	Discovery First Ed. 3.0 TD6 4x4 Die. Aut	64
2741	Discovery HSE 3.0 I6 Diesel Aut.	64
2742	Discovery HSE 3.0 V6 4x4 Aut.	64
2743	Discovery HSE 3.0 V6 4x4 TD6 Diesel Aut.	64
2744	Discovery HSE Lux. 3.0 TD6 4x4 Die. Aut.	64
2745	Discovery HSE Lux. 3.0 V6 4x4 Aut.	64
2746	Discovery R- Dyn HSE 3.0 4x4 Die. (Hib.)	64
2747	Discovery RAW 3.0 4x4 TDV6 Diesel Aut.	64
2748	Discovery R-Dynamic S 3.0 4x4 Die (Hib.)	64
2749	Discovery S 3.0 V6 4x4 Aut.	64
2750	Discovery S 3.0 V6 4x4 TD6 Diesel Aut.	64
2751	Discovery SE 3.0 I6 Diesel Aut.	64
2752	Discovery SE 3.0 V6 4x4 Aut.	64
2753	Discovery SE 3.0 V6 4x4 TD6  Diesel Aut.	64
2754	Discovery Sp. SE 2.0 4x4 Dies Aut.(Híb.)	64
2755	Discovery Sp. SE Dyn 2.0 P250 Flex Aut.	64
2756	Discovery Sp. SE Dyn 2.0 TB Die.(Híb.)	64
2757	Discovery Sp. SE R-Dyn 2.0 TB Die.(Híb.)	64
2758	Discovery Sport BLACK 2.2 4x4 Dies. Aut.	64
2759	Discovery Sport HSE 2.0 4x4 Aut/ Flex	64
2760	Discovery Sport HSE 2.0 4x4 Diesel Aut.	64
2761	Discovery Sport HSE 2.2 4x4 Diesel Aut.	64
2762	Discovery Sport HSE L. 2.0 4x4 Die. Aut.	64
2763	Discovery Sport HSE L. 2.2 4x4 Die. Aut.	64
2764	Discovery Sport HSE Lux. 2.0 4x4 /Flex	64
2765	Discovery Sport Landmark 2.0 4x4 Diesel	64
2766	Discovery Sport S 2.0 4x4 Flex Aut.	64
2767	Discovery Sport SE 2.0 4x4 Aut./Flex	64
2768	Discovery Sport SE 2.2 4x4 Diesel Aut.	64
2769	Discovery Sport SE R-Dyn 2.0 Si4 Flex	64
2770	Discovery TDI 2.5 Diesel	64
2771	Discovery Tempest 3.0 D350 4X4 Aut.	64
2772	Discovery3 HSE 2.7 4x4 TDI Diesel Aut.	64
2773	Discovery3 HSE 4.4 V8 4x4 299cv Aut.	64
2774	Discovery3 S 2.7 4x4 TDI Diesel Aut.	64
2775	Discovery3 S 4.0 V6 4x4 215cv Aut.	64
2776	Discovery3 SE 2.7 4x4 TDI Diesel Aut.	64
2777	Discovery3 SE 4.0 V6 4x4 215cv Aut.	64
2778	Discovery4 B&W 3.0 4x4 TDV6 Diesel Aut.	64
2779	Discovery4 BLACK 3.0 4x4 SDV6 Dies. Aut.	64
2780	Discovery4 GRAPHITE 3.0 4x4 SDV6 Die.Aut	64
2781	Discovery4 HSE 2.7 4x4 TDV6 Diesel Aut.	64
2782	Discovery4 HSE 3.0 4x4 TDV6/SDV6 Die.Aut	64
2783	Discovery4 HSE 5.0 4x4 Aut.	64
2784	Discovery4 S 2.7 4x4 TDV6 Diesel Aut.	64
2785	Discovery4 S 3.0 4X4 TDV6 Diesel Aut.	64
2786	Discovery4 SE 2.7 4x4 TDV6 Diesel Aut.	64
2787	Discovery4 SE 3.0 4x4 TDV6/SDV6 Die.Aut.	64
2788	Freelander 1.8 16v	64
2789	Freelander HSE 2.5 V6 24V 177cv 5p	64
2790	Freelander HSE3 2.5 V6 24V 177cv 3p	64
2791	Freelander S/ SE 2.5 V6 24V 177cv 5p	64
2792	Freelander SE3 2.5 V6 24V 177cv 3p	64
2793	Freelander2 Dynamique 2.2 SD4 T. Diesel	64
2794	Freelander2 HSE 2.2 SD4 190cv T.Diesel	64
2795	Freelander2 I6 HSE 3.2 232cv Aut. 5p	64
2796	Freelander2 I6 LE Sport 3.2 232cv Aut. 5	64
2797	Freelander2 I6 S 3.2 232cv Aut. 5p	64
2798	Freelander2 I6 S Sport 3.2 232cv Aut. 5p	64
2799	Freelander2 I6 SE 3.2 232cv Aut. 5p	64
2800	Freelander2 S 2.2 SD4 190cv T.Diesel	64
2801	Freelander2 SE 2.2 SD4 190cv T.Diesel	64
2802	Freelander2 Si4 Dyn. 2.0 240cv Aut. 5p	64
2803	Freelander2 Si4 HSE 2.0 240cv Aut. 5p	64
2804	Freelander2 Si4 S 2.0 240cv Aut. 5p	64
2805	Freelander2 Si4 SE 2.0 240cv Aut. 5p	64
2806	New Range/Range Rover Vogue 3.9 V8	64
2807	Range R. Autobio. 3.0 I6 TB Die. (Híb.)	64
2808	Range R. Autobio. 3.0 I6 TB P550e (Híb.)	64
2809	Range R. EVO HSE Si4 R-Dyn.2.0 300cv Aut	64
2810	Range R. EVO SE Si4 R-Dyn. 2.0 Flex Aut.	64
2811	Range R. First Ed.3.0 350cv Die.(Hib.)	64
2812	Range R. First.Ed. 4.4 V8 TB 530cv Aut.	64
2813	Range R. Sp. Dyn. HSE 3.0I6 Die. (Hib.)	64
2814	Range R. Sp. Dynam. HSE 3.0  (Híb.)	64
2815	Range R. Sp. First Ed. 3.0 510cv (Híb.)	64
2816	Range R. Sp.SVR AWD 5.0 Carbon Ed. Aut.	64
2817	Range R. Sport Autob. 3.0 SDV6 Diesel	64
2818	Range R. Sport Autob. 3.0 TB Die. (Híb.)	64
2819	Range R. Sport Autob. Dyn.SCHA. 5.0 V8	64
2820	Range R. Sport Autob. SUPERCHAR. 5.0 V8	64
2821	Range R. Sport Autobio. 3.0 P550e (Híb.)	64
2822	Range R. Sport HSE Dyna. 3.0 SDV6 Dies.	64
2823	Range R. Sport HSE Dynamic SUPERC.5.0 V8	64
2824	Range R. Sport HSE SUPERCHARGED 3.0 V6	64
2825	Range R. Sport HST SUPERCHARGED 3.0 V6	64
2826	Range R. Sport L. Edit. SCHARGED 3.0 V6	64
2827	Range R. Sport TECH S 3.0 SDV6 Diesel	64
2828	Range R. SV Autob. Sc. Dyn. SWB 5.0 V8	64
2829	Range R. SV Autob. Super. LWB 5.0 V8	64
2830	Range R. SVAutobiography SUPERC. 5.0 V8	64
2831	Range R. VE. R-Dyn HSE 2.0 4X4 300cv Aut	64
2832	Range R. VE. R-Dyn S 2.0 4X4 300cv Aut.	64
2833	Range R. VE. R-Dyn SE 2.0 4x4 250cv Aut.	64
2834	Range R. VE. R-Dyn SE 2.0 4x4 300cv Aut.	64
2835	Range R. VEL. R-Dyn HSE 3.0 Aut.(Híb.)	64
2836	Range R. VEL. R-Dyn. 2.0 4x4 250cv Aut.	64
2837	Range R. VEL. R-Dyn. 2.0 4x4 300cv Aut.	64
2838	Range R. VEL. R-Dyn. HSE 2.0 Aut. (Híb.)	64
2839	Range R. VEL. R-Dyn. S 2.0 Aut.(Híbrido)	64
2840	Range R. VEL. R-Dyn. SE 3.0 Aut. (Híb.)	64
2841	Range R. VELAR 2.0 4x4 TB 250cv Aut.	64
2842	Range R. VELAR 3.0 4x4 V6 380cv Aut.	64
2843	Range R. VELAR Autobio. 2.0 P400e (Híb)	64
2844	Range R. VELAR First Ed. 3.0 4x4 V6 Aut.	64
2845	Range R. VELAR HSE 2.0 4x4 TB 250cv Aut.	64
2846	Range R. VELAR HSE 3.0 4x4 V6 380cv Aut	64
2847	Range R. VELAR HSE Dyn 2.0 P400e (Hib.)	64
2848	Range R. Velar HSE R-Dyn 2.0 Si4(Hib.)	64
2849	Range R. VELAR R-Dyn. 3.0 4x4 V6 Aut.	64
2850	Range R. VELAR R-Dyn. HSE 2.0 4x4 TB Aut	64
2851	Range R. VELAR R-Dyn. HSE 3.0 4x4 V6 Aut	64
2852	Range R. VELAR R-Dyn. S 2.0 4x4 TB Aut.	64
2853	Range R. VELAR R-Dyn. S 3.0 4x4 V6 Aut.	64
2854	Range R. VELAR R-Dyn. SE 3.0 4x4 V6 Aut.	64
2855	Range R. VELAR S 2.0 4x4 TB 250cv Aut.	64
2856	Range R. VELAR S 2.0 4x4 TB 300cv Aut.	64
2857	Range R. VELAR S 3.0 4x4 V6 380cv Aut.	64
2858	Range R. VELAR SE 2.0 4x4 TB 250cv Aut.	64
2859	Range R. VELAR SE 3.0 4x4 V6 380cv Aut.	64
2860	Range R. VELAR SV Autob. Super.C 5.0 V8	64
2861	Range R. Vogue 4.4 TDV8/SDV8 Diesel Aut.	64
2862	Range R. Vogue Autob. SUPERCHAR. 5.0 V8	64
2863	Range R. Vogue/4.4 Autobio. SDV8 Diesel.	64
2864	Range R.EVO DYNAMIC. BLACK 2.0 Aut. 5p	64
2865	Range R.EVO STYLE 2.0 Aut. 5p	64
2866	Range R.EVOQ. HSE Dyn. Convers 2.0 Aut.	64
2867	Range R.EVOQUE Autob. 2.0 P250 Flex Aut	64
2868	Range R.EVOQUE Dynamic 2.0 Aut 3p	64
2869	Range R.EVOQUE Dynamic 2.0 Aut 5p	64
2870	Range R.EVOQUE Dynamic Tech 2.0 Aut 3p	64
2871	Range R.EVOQUE Dynamic Tech 2.0 Aut 5p	64
2872	Range R.EVOQUE HSE Dyna. 2.0 Dies. Aut.	64
2873	Range R.EVOQUE LONDON 2.0 240cv Aut. 5p	64
2874	Range R.EVOQUE ONE SICILIAN 2.0 Aut. 5p	64
2875	Range R.EVOQUE Prestige 2.0 Aut. 5p	64
2876	Range R.EVOQUE Prestige 2.2 5p Dies.	64
2877	Range R.EVOQUE Prestige Tech 2.0 Aut 5p	64
2878	Range R.EVOQUE PrestigeTech 2.2 5p Dies.	64
2879	Range R.EVOQUE Pure  2.0 Aut. 5p	64
2880	Range R.EVOQUE Pure 2.0 Aut. 3p	64
2881	Range R.EVOQUE SD4 HSE 2.2 Dies. Aut.5p	64
2882	Range R.EVOQUE SD4 SE 2.2 Dies. Aut. 5p	64
2883	Range R.EVOQUE Si4 HSE Dyn. 2.0/Flex Aut	64
2884	Range R.EVOQUE Si4 SE 2.0 Aut.5p/Flex	64
2885	Range R.EVOQUE Si4 SE Dynamic 2.0 Aut.	64
2886	Range R.Sp. First.Ed.4.4 V8 TB 530cv Aut	64
2887	Range R.Sp. SE 3.0 4x4 I6 TB Die. (Híb.)	64
2888	Range R.Sp.HSE Dyn.Bl. 3.0 I6 Die.(Híb.)	64
2889	Range R.Sport First.Ed.3.0 I6 Die.(Hib.)	64
2890	Range R.Sport HSE 3.0 I6 TB Die. (Híb.)	64
2891	Range R.Sport HSE Dynamic 4.4 SDV8 Dies.	64
2892	Range R.Sport SE 3.0 4x4 TDV6/SDV6 Dies.	64
2893	Range Rover Autobio 4.4 V8 TB 530cv Aut.	64
2894	Range Rover Autobio. 2.0 Si4 (Hibrido)	64
2895	Range Rover Autobio.3.0 I6 510cv (Híb.)	64
2896	Range Rover EVOQUE Autobiography 2.0 Aut	64
2897	Range Rover EVOQUE HSE 2.0 Diesel Aut.	64
2898	Range Rover EVOQUE Pure Tech 2.0 Aut. 3p	64
2899	Range Rover EVOQUE Pure Tech 2.0 Aut. 5p	64
2900	Range Rover EVOQUE SE 2.0 Diesel Aut.	64
2901	Range Rover EVOQUE Zanzibar 2.0 Aut. 5p	64
2902	Range Rover HSE 3.0 I6 510cv (Híbrido)	64
2903	Range Rover HSE 4.4/ 4.6	64
2904	Range Rover SE 3.0 I6 510cv (Híbrido)	64
2905	Range Rover SE 4.4 V8 TB 530cv Aut.	64
2906	Range Rover SE. 3.0 I6 TB Die. (Híb.)	64
2907	Range Rover Sport 3.6 TDV8 272cv Diesel	64
2908	Range Rover Sport Dynamic HSE 3.0 4X4 P550e	64
2909	Range Rover Sport HSE 2.0 Si4 (Híbrido)	64
2910	Range Rover Sport HSE 2.7 190cv TB Dies.	64
2911	Range Rover Sport HSE 3.0 4x4 SDV6 Dies.	64
2912	Range Rover Sport HSE 4.4 V8 32V 295cv	64
2913	Range Rover Sport HSE SUPERCHAR. 5.0 V8	64
2914	Range Rover Sport SE 2.7 190cv TB Diesel	64
2915	Range Rover Sport SE 3.6 TDV8 272cv Dies	64
2916	Range Rover Sport SE 4.4 V8 32V 299cv	64
2917	Range Rover Sport SE Dy.3.0 I6 Die.(Hib)	64
2918	Range Rover Sport SE SUPERCH. 3.0  Aut.	64
2919	Range Rover Sport SUPERCHAGED 4.2 V8	64
2920	Range Rover Sport SVR SUPERCHA. 5.0 V8	64
2921	Range Rover SUPERCHARGED 4.2 V8 396cv	64
2922	Range Rover SV 3.0 I6 TB (Híb.)	64
2923	Range Rover SV 4.4 V8 TB 530cv Aut.	64
2924	Range Rover SV. 3.0 I6 TB Die. (Híb.)	64
2925	Range Rover Vogue 3.0 TDV6 Diesel Aut.	64
2926	Range Rover Vogue 3.6 TDV8 272cv Diesel	64
2927	Range Rover Vogue HSE 3.0 TDV6 Diesel	64
2928	Range Rover Vogue SE 2.0 Si4 (Híbrido)	64
2929	Range Rover Vogue SE 4.4 SDV8 Dies. Aut	64
2930	Range Rover Vogue SE SUPERCHAR. 5.0 V8	64
2931	Range.R. SP.HSE Dyn.BL. 2.0 Si4(Hibrido)	64
2932	350Z 3.5 V6 280cv/ 312cv 2p	82
2933	Altima GXE 2.4 16V	82
2934	Altima SE 2.4 16V	82
2935	ALTIMA SL 2.5 16V 4p Aut.	82
2936	AX 6.5D Turbo Diesel	82
2937	D-21 Pick-Up CD 4x2/4x4 2.7 Diesel	82
2938	D-21 Pick-Up CS 4x2/4x4 2.7 Diesel	82
2939	Frontier ATTAC.CD 4x4 2.3 Bi-TB Die. Aut	82
2940	Frontier AX 3.2 CD Diesel	82
2941	Frontier AX CD 4x4 2.5 TB Interc. Diesel	82
2942	Frontier DX 3.2 CD Diesel	82
2943	Frontier LE ATTACK CD 4x4 2.5 TB Die.Aut	82
2944	Frontier LE CD 4x4 2.3 Bi-TB Diesel Aut.	82
2945	Frontier LE CD 4x4 2.5 TB dies.(Import.)	82
2946	Frontier LE CD 4x4 2.5 TB Diesel Aut.	82
2947	Frontier LE CD 4x4 2.5 TB Diesel Mec.	82
2948	Frontier PLATI. CD  2.3 Bi-TB Dies.Aut.	82
2949	Frontier PLATINUM CD 4x4 2.5 TB Diesel	82
2950	Frontier PRO4X CD 4x4 2.3 Bi-TB Die. Aut	82
2951	Frontier S CD 4x2 2.5 TB Diesel	82
2952	Frontier S CD 4x4 2.3 TB Diesel Mec.	82
2953	Frontier S CD 4x4 2.5 TB Diesel	82
2954	Frontier SE ATTACK CD 4x2 2.5 TB Diesel	82
2955	Frontier SE ATTACK CD 4x4 2.5 TB Diesel	82
2956	Frontier SE CD 4x4 2.3 Bi-TB Diesel Aut.	82
2957	Frontier SE Serrana CD 4x4 2.8 TB Dies	82
2958	Frontier SE Vibe CD 2.8 TDI Dies.	82
2959	Frontier SE/ SE ONE CD 4x2 2.8 TDI Dies	82
2960	Frontier SE/SE Strik CD 4x2 2.5 TB Dies.	82
2961	Frontier SE/SE Strik CD 4x4 2.5 TB Dies.	82
2962	Frontier SE/SE Strik/ONE CD 4x4 2.8 Dies	82
2963	Frontier SEL CD 4x4 2.5 TB Diesel	82
2964	Frontier SEL CD 4x4 2.5 TB Diesel Aut.	82
2965	Frontier SL CD 4x4 2.5TB Diesel Aut	82
2966	Frontier SV AT. CD 4x4 2.5 TB Dies. Aut.	82
2967	Frontier SV AT.CD 4x4 2.5 TB Diesel Mec.	82
2968	Frontier SV ATTACK CD 4x2 2.5 TB Diesel	82
2969	Frontier XE  CD 4x4 2.5 TB Diesel	82
2970	Frontier XE ATTACK CD 2.8 TDI Diesel	82
2971	Frontier XE CD 4x2 2.5 TB Diesel	82
2972	Frontier XE CD 4x4 2.3 Bi-TB Diesel Aut.	82
2973	Frontier XE CS 4x2 2.8 TB Interc. Dies.	82
2974	Frontier XE/ XE TIT. CD 4x2 2.8 TDI Dies	82
2975	Frontier XE/ XE TIT. CD 4x4 2.8 TDI Dies	82
2976	Frontier X-GEAR CD 4x4 2.3 Bi-TB Die.Aut	82
2977	GT-R 3.8 V6 BiTurbo Aut.	82
2978	Infinit 3.0	82
2979	Kait Active 1.6 16v Aut.	82
2980	Kait Advance Plus 1.6 16v Aut.	82
2981	Kait Exclusive 1.6 16v Aut.	82
2982	Kait Sense Plus 1.6 16v Aut.	82
2983	KICKS Active 1.6 16V Flex Aut.	82
2984	KICKS Active S 1.6 16V Flex Aut.	82
2985	KICKS Advance 1.0 Turbo Flex Aut.	82
2986	KICKS Advance 1.6 16V Flex Aut.	82
2987	KICKS Exclusive 1.0 Turbo Flex Aut.	82
2988	KICKS Exclusive 1.6 16V Flex Aut.	82
2989	KICKS Platinum 1.0 Turbo Flex Aut.	82
2990	KICKS Play Active Plus 1.6 16V Flex Aut.	82
2991	KICKS Play Advance Plus 1.6 16V Flex Aut	82
2992	KICKS Play Sense 1.6 16V Flex Aut.	82
2993	KICKS Rio 2016 1.6 16V FlexStar 5p Aut.	82
2994	KICKS S 1.6 16V Flex 5p Aut.	82
2995	KICKS S 1.6 16V FlexStar 5p Mec.	82
2996	KICKS S Direct 1.6 16V Flex 5p Aut.	82
2997	KICKS Sense 1.0 Turbo Flex Aut.	82
2998	KICKS Sense 1.6 16V Flex Aut.	82
2999	KICKS Sense 1.6 16V Flex Mec.	82
3000	KICKS SL 1.6 16V FlexStar 5p Aut.	82
3001	KICKS Special Ed. 1.6 16V Flex 5p Aut.	82
3002	KICKS Special Ed.1.6 16V Flex 5p Mec.	82
3003	KICKS SV 1.6 16V FlexStar 5p Aut.	82
3004	KICKS SV Limited 1.6 16V Flex 5p Aut.	82
3005	KICKS UCL 1.6 16V Flex 5p Aut.	82
3006	KICKS XPlay 1.6 16V Flex Aut.	82
3007	King-Cab SE 4x4 3.0 V6	82
3008	LEAF Aut. (Elétrico)	82
3009	LIVINA 1.6 16V Flex Fuel 5p	82
3010	LIVINA 1.8 16V Flex Fuel Aut.	82
3011	LIVINA GRAND 1.8 16V Flex Fuel Aut.	82
3012	LIVINA GRAND 1.8 16V Flex Fuel Mec.	82
3013	LIVINA GRAND S 1.8 16V Flex Fuel Aut.	82
3014	LIVINA GRAND S 1.8 16V Flex Fuel Mec.	82
3015	LIVINA GRAND SL 1.8 16V Flex Fuel Aut.	82
3016	LIVINA GRAND SL 1.8 16V Flex Fuel Mec	82
3017	LIVINA NIGHT&DAY 1.6 16V Flex Fuel Mec.	82
3018	LIVINA S 1.6 16V Flex Fuel Mec.	82
3019	LIVINA S 1.8 16V Flex Fuel Aut.	82
3020	LIVINA SL 1.6 16V Flex Fuel 5p	82
3021	LIVINA SL 1.8 16V Flex Fuel Aut.	82
3022	LIVINA X-GEAR 1.6 16V Flex Fuel Mec.	82
3023	LIVINA X-GEAR S 1.6 16V Flex Fuel	82
3024	LIVINA X-GEAR SL 1.6 16V Flex Fuel Mec.	82
3025	LIVINA X-GEAR SL/X-GEAR 1.8 Flex F. Aut.	82
3026	MARCH 1.0 12V Flex 5p	82
3027	MARCH 1.0 12V FlexStart 5p	82
3028	MARCH 1.0 16V Flex Fuel 5p	82
3029	MARCH Rio2016 1.0 Flex Fuel 5p	82
3030	MARCH Rio2016 1.6 Flex Fuel 5p	82
3031	MARCH S 1.0 12V Flex 5p	82
3032	MARCH S 1.0 16V Flex Fuel 5p	82
3033	MARCH S 1.6 16V Flex Fuel 5p	82
3034	MARCH S 1.6 16V FlexStart 5p	82
3035	MARCH SL 1.6 16V Flex Fuel 5p	82
3036	MARCH SL 1.6 16V FlexStart 5p Aut.	82
3037	MARCH SL 1.6 16V FlexStart 5p Mec.	82
3038	MARCH SR 1.6 16V Flex Fuel 5p	82
3039	MARCH SV 1.0 12V Flex 5p	82
3040	MARCH SV 1.0 16V Flex Fuel 5p	82
3041	MARCH SV 1.6 16V Flex Fuel	82
3042	MARCH SV 1.6 16V FlexStart 5p Aut.	82
3043	MARCH SV 1.6 16V FlexStart 5p Mec.	82
3044	Maxima 30G/ GLE 3.0 V6 24V	82
3045	Maxima 30GV  Limited 3.0 V6 24V	82
3046	Maxima 30GV/30GV Aero/ GV 3.0 V6 24V	82
3047	Maxima 30J	82
3048	Maxima GXE 3.0	82
3049	Maxima SE 3.0 V6	82
3050	Micra 1.0	82
3051	MURANO SE 3.5 V6 24V 231cv Aut	82
3052	NX 2000	82
3053	NX 2000 Targa 2.0	82
3054	Pathfinder LE 2.5 16V TDI Diesel Aut	82
3055	Pathfinder LE 4.0 V6 24V 266cv Aut	82
3056	Pathfinder SE 2.5 16V TDI Diesel Aut.	82
3057	Pathfinder SE 3.3 V6 12V	82
3058	Pathfinder SE 4.0 V6 24V 266cv Aut.	82
3059	Pathfinder SE 4x4 3.0 12V Aut./Mec.	82
3060	Pathfinder SE Luxo 3.3 V6 12V	82
3061	Pathfinder SE Luxo 3.5 V6 24V 243cv	82
3062	Pathfinder SE Titanium 3.3 V6 12V	82
3063	Pathfinder XE 2.7 TB Diesel	82
3064	Pathfinder XE 4x4	82
3065	Pick-Up CD AX/ DX 4x4 Diesel	82
3066	Pick-Up CS DX 4x4 Diesel	82
3067	Pick-Up King Cab DX 2.7 4x2 Diesel	82
3068	Primera GXE 2.0 16V	82
3069	Quest GXE/ GLE/ SER	82
3070	Quest XE 3.0 V6	82
3071	Sentra 2.0/ 2.0 Flex Fuel 16V Aut.	82
3072	Sentra 2.0/ 2.0 Flex Fuel 16V Mec.	82
3073	Sentra Advance 2.0 16V Aut.	82
3074	Sentra Exclu. Int. Premium 2.0 16V Aut.	82
3075	Sentra Exclusive 2.0 16V Aut.	82
3076	Sentra GLE	82
3077	Sentra GSX/ EX	82
3078	Sentra GXE/ SER	82
3079	Sentra S 2.0 FlexStart 16V Aut.	82
3080	Sentra S 2.0/ 2.0 Flex Fuel 16V Aut.	82
3081	Sentra S 2.0/ 2.0 Flex Fuel 16V Mec.	82
3082	Sentra SE 2.0 Flex 16V Aut.	82
3083	Sentra SL 2.0 FlexStart 16V Aut.	82
3084	Sentra SL 2.0/ 2.0 Flex Fuel 16V Aut.	82
3085	Sentra SR 2.0 Flex Fuel 16V Aut.	82
3086	Sentra SR 2.0 Flex Fuel 16V Mec.	82
3087	Sentra SV 2.0 FlexStart 16V Aut.	82
3088	Sentra UNIQUE 2.0 Flex Fuel 16V Aut.	82
3089	Stanza XE 2.4 12V	82
3090	SX 240 2.4	82
3091	Terrano II SE 2.7 Diesel	82
3092	Terrano II SLX 2.7 Diesel	82
3093	TIIDA S 1.8/1.8 Flex 16V  Mec.	82
3094	TIIDA S 1.8/1.8 Flex 16V Aut.	82
3095	TIIDA Sedan 1.8 16V Flex Fuel 4p	82
3096	TIIDA Sedan 1.8 16V Flex Fuel 4p Aut.	82
3097	TIIDA SL 1.8/1.8 Flex 16V  Mec.	82
3098	TIIDA SL 1.8/1.8 Flex 16V Aut.	82
3099	VERSA 1.0 12V FlexStart 4p Mec.	82
3100	VERSA Advance 1.6 16V Flex Aut.	82
3101	VERSA Exclusive 1.6 16V Flex Aut.	82
3102	VERSA S 1.0 12V FlexStart 4p Mec.	82
3103	VERSA S 1.6 16V Flex Fuel 4p Mec.	82
3104	VERSA S 1.6 16V FlexStart 4p Mec.	82
3105	VERSA Sense 1.6 16V Flex Aut.	82
3106	VERSA Sense 1.6 16V Flex Mec.	82
3107	VERSA SL 1.6 16V Flex Fuel 4p Mec.	82
3108	VERSA SL 1.6 16V FlexStart 4p Aut.	82
3109	VERSA SL 1.6 16V FlexStart 4p Mec.	82
3110	VERSA SL Direct 1.6 16V Flex  Aut. 	82
3111	VERSA Special Ed. 1.6 16V FlexStart Aut.	82
3112	VERSA SR 1.6 16V Flex Aut.	82
3113	VERSA SV 1.6 16V Flex Fuel 4p Mec.	82
3114	VERSA SV 1.6 16V FlexStart 4p Aut.	82
3115	VERSA SV 1.6 16V FlexStart 4p Mec.	82
3116	VERSA UNIQUE 1.6 16V Flex 4p Mec.	82
3117	VERSA UNIQUE 1.6 16V FlexStart 4p Aut.	82
3118	VERSA V-DRIVE 1.0  12V Flex Mec.	82
3119	VERSA V-DRIVE 1.6 16V Flex Mec.	82
3120	VERSA V-DRIVE Esp.Ed. 1.6 16v Flex Aut.	82
3121	VERSA V-DRIVE PLUS 1.6 16V Flex Aut.	82
3122	VERSA V-DRIVE Premium 1.6 16v Flex Aut.	82
3123	XTerra ECOTRIP 4x4 140cv 2.8 TB Int.Dies	82
3124	XTerra SE 4x4 2.8 132/140cv TB Int.Dies.	82
3125	XTerra XE 4x4 2.8 132cv TB Int. Diesel	82
3126	X-TRAIL GX 2.5 16V 180cv 5p	82
3127	X-TRAIL LE 2.0 16V 138cv Aut.	82
3128	X-TRAIL SE 2.0 16V 138cv Aut.	82
3129	ZX 300 3.0 BI-Turbo	82
3130	106 KID 1.0	84
3131	106 Passion 1.0 3p	84
3132	106 Passion 1.0 5p	84
3133	106 Quiksilver 1.0 3p	84
3134	106 Selection 1.0 3p	84
3135	106 Selection 1.0 5p	84
3136	106 Soleil 1.0 3p	84
3137	106 Soleil 1.0 5p	84
3138	106 XN 3p e 5p	84
3139	106 XT	84
3140	2008 Active 1.0 Turbo Flex 5p Aut.	84
3141	2008 Allure 1.0 Turbo 200 5p Aut.	84
3142	2008 Allure 1.0 Turbo Flex 5p Aut.	84
3143	2008 Allure 1.6 Flex 16V 5p Aut.	84
3144	2008 Allure 1.6 Flex 16V 5p Mec.	84
3145	2008 Allure Bus. 1.6 Flex 5p Aut.	84
3146	2008 Allure Essencial 1.6 Flex 16V Aut.	84
3147	2008 Allure Pack 1.6 Flex 16V Aut.	84
3148	2008 Allure Pack Bus. 1.6 Flex Aut.	84
3149	2008 Crossway 1.6 Flex 16V 5p Aut.	84
3150	2008 Griffe 1.6 Flex 16V 5p Aut.	84
3151	2008 Griffe 1.6 Flex 16V 5p Mec.	84
3152	2008 Griffe 1.6 Turbo Flex 16V 5p Aut.	84
3153	2008 Griffe 1.6 Turbo Flex 16V 5p Mec.	84
3155	2008 GT 1.0 Turbo Flex 5p Aut.	84
3156	2008 Roadtrip 1.6 Flex 16V 5p Aut.	84
3157	2008 SKYWALKER 1.6 Turbo Flex 16V Aut.	84
3158	2008 Style 1.6 Flex 16V 5p Aut.	84
3159	2008 Style 1.6 Turbo Flex 16V 5p Aut.	84
3160	205 CJ Cabriolet	84
3161	205 CTi Cabriolet 1.4	84
3162	205 GTi 1.4	84
3163	205 XSi/ Junior 1.4 3p	84
3164	206 Allure 1.6 Flex 16V 3p	84
3165	206 Allure 1.6 Flex 16V 5p	84
3166	206 Automatic (feline)1.6 Flex 16V 5p	84
3167	206 CC 1.6 16V 2p	84
3168	206 Feline 1.4/ 1.4 Flex 8V 5p	84
3169	206 Holiday 1.4 8V 75cv 3p	84
3170	206 Holiday 1.4 8V 75cv 5p	84
3171	206 Holiday 1.6 Flex 16V 3p	84
3172	206 Holiday 1.6 Flex 16V 5p	84
3173	206 Moonlight 1.4 Flex 8V 3p	84
3174	206 Moonlight 1.4 Flex 8V 5p	84
3175	206 Passion 1.6	84
3176	206 Passion 1.6 16v 110cv 5p	84
3177	206 Presence 1.4/ 1.4 Flex 8V 3p	84
3178	206 Presence 1.4/ 1.4 Flex 8V 5p	84
3179	206 Rallye 1.6	84
3180	206 Rallye 1.6/ 1.6 Flex 16v 110cv 3p	84
3181	206 Select./Presence 1.6/1.6 Flex 16V 5p	84
3182	206 Selection 1.6 16V 110cv 3p	84
3183	206 Selection/ Sensation 1.0 16v 3p	84
3184	206 Selection/ Sensation 1.0 16v 5p	84
3185	206 Sensation 1.4 Flex 8V 3p	84
3186	206 Sensation 1.4 Flex 8V 5p	84
3187	206 Soleil 1.0 16v 5p	84
3188	206 Soleil 1.6 16v 110cv 5p	84
3189	206 Soleil 1.6 3p	84
3190	206 Soleil 1.6 5p	84
3191	206 Soleil/Quiksilver 1.0 16V 3p	84
3192	206 Soleil/Quiksilver 1.6 16V 110cv 3p	84
3193	206 SW Automatic (feline)1.6 Flex 16V 5p	84
3194	206 SW ESCAPADE 1.6 16V Flex 5p	84
3195	206 SW Feline 1.6/ 1.6 Flex 16V 5p	84
3196	206 SW Moonlight 1.4 Flex 8V 5p	84
3197	206 SW Presence 1.4/ 1.4 Flex 8V 5p	84
3198	206 SW Presence 1.6/1.6 Flex 16V 5p	84
3199	206 Techno 1.0 16V 70cv 5p	84
3200	206 Techno/ Feline 1.6/ 1.6 Flex 16V 5p	84
3201	207 Active 1.4 Flex 8V 5p	84
3202	207 Blue Lion 1.4 Flex 8V 5p	84
3203	207 QUIKSILVER 1.4 Flex 8V 3p	84
3204	207 QUIKSILVER 1.4 Flex 8V 5p	84
3205	207 QUIKSILVER 1.6 Flex 16V 5p	84
3206	207 Sed. Passion XR Sport 1.4 Flex 8V 4p	84
3207	207 Sedan Active 1.4 Flex 8V 4p	84
3208	207 Sedan Allure 1.4 Flex 8v 4p	84
3209	207 Sedan Passion XR 1.4 Flex 8V 4p	84
3210	207 Sedan Passion XS 1.6 Flex 16V 4p	84
3211	207 Sedan Passion XS 1.6 Flex 16V 4p Aut	84
3212	207 SW ESCAPADE 1.6 16V Flex 5p	84
3213	207 SW XR 1.4 Flex 8V 5p	84
3214	207 SW XR Sport 1.4 Flex 8V 5p	84
3215	207 SW XS 1.6 Flex 16V 5p Aut.	84
3216	207 X-Line 1.4 Flex 8V 3p	84
3217	207 X-Line 1.4 Flex 8V 5p	84
3218	207 XR 1.4 Flex 8V 3p	84
3219	207 XR 1.4 Flex 8V 5p	84
3220	207 XR Sport 1.4 Flex 8V 3p	84
3221	207 XR Sport 1.4 Flex 8V 5p	84
3222	207 XS 1.6 Flex 16V 3p	84
3223	207 XS 1.6 Flex 16V 5p	84
3224	207 XS 1.6 Flex 16V 5p Aut.	84
3225	208 Active 1.0 Flex 5p Mec.	84
3226	208 Active 1.0 Turbo 200 5p Aut.	84
3227	208 Active 1.2 Flex 12V 5p Mec.	84
3228	208 Active 1.6 Flex 16V 5p Aut.	84
3229	208 Active Pack 1.2 Flex 12V 5p Mec.	84
3230	208 Active Pack 1.6 Flex 16V 5p Aut.	84
3231	208 Active/Active Pack 1.5 Flex 8V 5p	84
3232	208 Allure 1.0 Turbo 200 5p Aut.	84
3233	208 Allure 1.0 Turbo Flex 5p Aut.	84
3234	208 Allure 1.2 Flex 12V 5p Mec.	84
3235	208 Allure 1.5 Flex 8V 5p	84
3236	208 Allure 1.6 Flex 16V 5p Aut.	84
3237	208 Allure inconcert 1.5 Flex 8V 5p Mec.	84
3238	208 Allure inconcert 1.6 Flex 16V 5p Aut	84
3239	208 Griffe 1.0 Turbo Flex 5p Aut.	84
3240	208 Griffe 1.6 Flex 16V 5p Aut.	84
3241	208 Griffe 1.6 Flex 16V 5p Mec.	84
3242	208 Griffe Bus. 1.6 Flex 5p Aut.	84
3243	208 GT 1.0 Turbo 200 5p Aut.	84
3244	208 GT 1.0 Turbo Flex 5p Aut.	84
3245	208 GT 1.6 THP Flex 16V 5p Mec.	84
3246	208 Inconcert 1.6 Flex 16V 5p Aut.	84
3247	208 Like 1.0 Flex 6V 5p Mec.	84
3248	208 Like 1.6 Flex 16V 5p Mec.	84
3249	208 Like Essencial 1.6 Flex 16V 5p Mec.	84
3250	208 Premier 1.6 Flex 16V 5p	84
3251	208 Roadtrip 1.6 Flex 16V 5p Aut.	84
3252	208 Sport 1.6 Flex 16V 5p Mec.	84
3253	208 Style 1.0 Flex 6V 5p Mec.	84
3254	208 Style 1.0 Turbo Flex 5p Aut.	84
3255	208 URBANTECH1.6 Flex 16V 5p Aut.	84
3256	3008 Allure 1.6 Turbo 16V 5p Aut.	84
3257	3008 Griffe 1.6 Turbo 16V 5p Aut.	84
3258	3008 Griffe Pack 1.6 Turbo 16V 5p Aut.	84
3259	3008 GT Pack 1.6 Turbo 16V 5p Aut.	84
3260	3008 Roland Garros 1.6 Turbo 16V 5p	84
3261	306 Break Passion 1.8 16V	84
3262	306 Cabriolet 1.8/ Mi 16V	84
3263	306 Cabriolet 2.0	84
3264	306 GTi 2.0 16V	84
3265	306 Passion 1.8 16V	84
3266	306 Passion Sedan 1.8 16V	84
3267	306 Rallye 1.8 16V	84
3268	306 S16 2.0 3p	84
3269	306 Selection Hatch 1.8 16V	84
3270	306 Selection Sedan 1.8 16V	84
3271	306 Si/ SL 1.8	84
3272	306 Soleil 1.8 16V  4p	84
3273	306 Soleil 1.8 16V 2p	84
3274	306 Soleil Break 1.8 16V 5p	84
3275	306 Soleil Hatch 1.8 16V 5p	84
3276	306 SR	84
3277	306 XN 1.8	84
3278	306 XR 1.8 / XR Break 1.8 16V	84
3279	306 XS 1.6 3p/ ST 1.8i 4p	84
3280	306 XSi 2.0 3/5p	84
3281	307 CC 2.0 16V 138cv 2p Mec.	84
3282	307 CC 2.0 16V 2p Aut.	84
3283	307 Feline 2.0/2.0 Flex 16V 5p Mec.	84
3284	307 Feline/Griff/Premi. 2.0 Flex 5p Aut.	84
3285	307 MILLESIM200 1.6 Flex 16V 5p	84
3286	307 Passion 1.6 16V 110cv 5p	84
3287	307 Passion 2.0 16V 138cv 5p	84
3288	307 Presence 2.0 Flex 16V 5p Aut.	84
3289	307 Rallye 1.6 16V 110cv 5p	84
3290	307 Rallye 2.0 16V 138cv 5p	84
3291	307 Rallye 2.0 16V 138cv 5p Aut.	84
3292	307 Sed. Feline 2.0/2.0 Flex 16V 4p Mec.	84
3293	307 Sed. Presence 1.6 Flex 16V 4p	84
3294	307 Sed. Presence 2.0 Flex 16V 5p Aut.	84
3295	307 Sed.Feline/Griff 2.0/2.0 Flex 4p Aut	84
3296	307 Soleil/ Presence 1.6/1.6 Flex 16V 5p	84
3297	307 SW 2.0 16V 138cv 5p Mec.	84
3298	307 SW 2.0 16V 5p Aut.	84
3299	307 SW Allure 2.0 16V 5p Aut.	84
3300	307 SW Allure 2.0 16V 5p Mec.	84
3301	307 SW Feline 2.0 16V 5p Aut.	84
3302	308 Active 1.6 Flex 16V 5p mec.	84
3303	308 Allure 1.6 Flex 16V 5p Mec.	84
3304	308 Allure 1.6 Turbo Flex 16V 5p Aut.	84
3305	308 Allure 2.0 Flex 16V 5p Aut.	84
3306	308 Allure 2.0 Flex 16V 5p Mec.	84
3307	308 Bus. Pro 1.6 TB Flex 5p Aut.	84
3308	308 Business 1.6 Turbo Flex 16V 5p Aut.	84
3309	308 CC 1.6 Turbo 16V 2p Aut.	84
3310	308 CC Roland Garros 1.6 Turbo16V 2p Aut	84
3311	308 Feline 2.0 Flex 16V 5p Aut.	84
3312	308 Feline/Griffe 1.6 Turbo 16V 5p Aut.	84
3313	308 Griffe 1.6 Turbo Flex 16V 5p Aut.	84
3314	308 QUIKSILVER 1.6 Flex 16V 5p Mec.	84
3315	308 Roland Garros 1.6 TB Flex 16V 5p Aut	84
3316	308 Roland Garros 1.6 Turbo 16V 5P	84
3317	405 GLi/ GL 1.6	84
3318	405 GRi 1.8	84
3319	405 Mi 2.0 16V	84
3320	405 SRi 1.8	84
3321	405 SRi 2.0	84
3322	405 SRi Break	84
3323	405 STi	84
3324	406 Break 2.0 16V	84
3325	406 Break 3.0 V6 24V	84
3326	406 Break ST 2.0	84
3327	406 Cupê 3.0 24V Aut.	84
3328	406 Cupê 3.0 24V Mec.	84
3329	406 Familiale 2.0 16V Aut.	84
3330	406 Familiale 2.0 16V Mec.	84
3331	406 Sedan 2.0 Aut.	84
3332	406 Sedan 2.0 Mec.	84
3333	406 Sedan 3.0 V6 24V	84
3334	406 ST 2.0 16V  Mec	84
3335	406 ST/ SVA 2.0 16V Aut	84
3336	406 SV 2.0 16V	84
3337	406 SVA 3.0 24V	84
3338	406 SVE 3.0 24V	84
3339	407 Sed. Allure 2.0 16V 4p Aut.	84
3340	407 Sed. Feline 3.0 V6 211cv 4p Aut.	84
3341	407 Sed. Griffe 3.0 V6 211cv 4p Aut.	84
3342	407 Sedan 2.0 16V  138cv 4p Aut.	84
3343	407 Sedan 3.0 V6 211cv 4p Aut.	84
3344	407 SW 2.0 16V 5p Aut.	84
3345	407 SW 3.0 V6 211cv 5p Aut.	84
3346	407 SW Allure 2.0 16V 5p Aut.	84
3347	407 SW Feline 3.0 V6 211cv 5p Aut.	84
3348	408 Sed. Bus. Pro 1.6 TB Flex Aut.	84
3349	408 Sed. Bus./Allure 1.6 TB Flex 16V Aut	84
3350	408 Sed. R.Garros 1.6 TB Flex 16V 4p Aut	84
3351	408 Sedan Allure 2.0 Flex 16V 4p Aut.	84
3352	408 Sedan Allure 2.0 Flex 16V 4p Mec.	84
3353	408 Sedan Feline 2.0 Flex 16V 4p Aut.	84
3354	408 Sedan Griffe 1.6 TB Flex 16V 4p Aut.	84
3355	408 Sedan Griffe 1.6 Turbo 16V 4p Aut.	84
3356	408 Sedan Griffe 2.0 Flex 16V 4p Aut.	84
3357	408 Sedan Limited 2.0 Flex 16V 4p Aut.	84
3358	5008 Griffe 1.6 Turbo 16V 5p Aut.	84
3359	5008 Griffe Pack 1.6 Turbo 16V 5p Aut.	84
3360	504 GD 2.3 Diesel	84
3361	504 GRD 2.3 Diesel	84
3362	505 SR/ SRi/ SRX	84
3363	508 THP 1.6 Turbo 16V 4p Aut.	84
3364	605 SRi 3.0	84
3365	605 SRi/ SLi 2.0	84
3366	605 SV 3.0 Aut.	84
3367	605 SV-3 3.0 V6 24V	84
3368	607 Sedan 3.0 V6	84
3369	806 ST Turbo	84
3370	806 SV 2.0 Turbo	84
3371	807 2.0 16V 138cv 5p Aut.	84
3372	Boxer 2.3 Furg.TB Dies. Curto/Médio	84
3373	Boxer 2.3 Furg.TB Dies. Méd/ LongoT.Alto	84
3374	Boxer 2.3 LH Executive 15/16L TB Diesel	84
3375	Boxer 2.3 Minibus 15/16L TB Diesel.	84
3376	Boxer 2.5 Diesel	84
3377	Boxer 2.8 10Lug. Diesel	84
3378	Boxer 2.8 Furg. TB Dies. Méd/LongoT.Alto	84
3379	Boxer 2.8 Furgão Dies/ TB Dies.curto/méd	84
3380	Boxer 2.8 Van Diesel/TB Diesel 15L/16L	84
3381	Boxer Business Furgão 2.0 Turbo Diesel	84
3382	Boxer Cargo 2.2 Turbo Diesel	84
3383	Boxer Cargo Furgão 2.0 Turbo Diesel 	84
3384	Boxer Furgão 2.2 Turbo Diesel 	84
3385	Boxer Minibus 2.0 16L Turbo Diesel	84
3386	Boxer Minibus Exec. 2.2 17L Turbo Diesel	84
3387	Boxer Vidrado 2.2 Turbo Diesel	84
3388	e-2008 GT 5p Aut. ( Elétrico)	84
3389	e-208 GT 5p Aut. (Elétrico)	84
3390	E-Expert Cargo 136cv (Elétrico)	84
3391	Expert Business 1.6 Turbo Diesel	84
3392	Expert Business Pack 1.6 Turbo Diesel	84
3393	Expert Cargo 1.5 Turbo Diesel	84
3394	Expert Cargo 2.2 Turbo Diesel	84
3395	Expert Minibus 1.6 Turbo Diesel	84
3396	Expert VITRÉ 1.5 Turbo Diesel	84
3397	Expert VITRÉ 1.6 Turbo Diesel	84
3398	Expert VITRÉ 2.2 Turbo Diesel	84
3399	HOGGAR Active 1.4 Flex 8V 2p	84
3400	HOGGAR Allure 1.4 Flex 8V 2p	84
3401	HOGGAR ESCAPADE 1.6 Flex 16V 2p	84
3402	HOGGAR X-Line 1.4 Flex 8V 2p	84
3403	HOGGAR XR 1.4 Flex 8V 2p	84
3404	Partner  VAN 1.6  Flex 16V  5p	84
3405	Partner  VAN ESCAPADE 1.6 Flex 16V 5p	84
3406	Partner Furgão 1.6 16V/ 1.6 16V Flex 3p	84
3407	Partner Furgão 1.8 3p	84
3408	Partner Rapid Busin. Pack 1.3 Flex Mec.	84
3409	Partner Rapid Busin. Pack 1.4 Flex Mec.	84
3410	Partner Rapid Busin.1.4 Flex Mec.	84
3411	RCZ 1.6 Turbo 16V 2p Aut.	84
3412	AMAROK CD2.0 16V/S CD2.0 16V TDI 4x2 Die	106
3413	AMAROK CD2.0 16V/S CD2.0 16V TDI 4x4 Die	106
3414	AMAROK Comfor. 3.0 V6 TDI 4x4 Dies. Aut.	106
3415	AMAROK Comfor. CD 2.0 TDI 4x4 Dies. Aut.	106
3416	AMAROK CS2.0 16V/S2.0 16V TDI 4x2 Diesel	106
3417	AMAROK CS2.0 16V/S2.0 16V TDI 4x4 Diesel	106
3418	AMAROK Extreme CD 3.0 4x4 TB Dies. Aut.	106
3419	AMAROK Hig. Extreme CD 2.0 4x4 Dies. Aut	106
3420	AMAROK Hig.ULTIMATE CD 2.0 4x4 Dies. Aut	106
3421	AMAROK High.CD 2.0 16V TDI 4x4 Dies. Aut	106
3422	AMAROK Highline CD 2.0 16V TDI 4x4 Dies.	106
3423	AMAROK Highline CD 3.0 4x4 TB Dies. Aut.	106
3424	AMAROK SE CD 2.0 16V TDI 4x4 Diesel	106
3425	AMAROK T. Dark Label CD 2.0 4x4 Dies Aut	106
3426	AMAROK Trendline CD 2.0 16V TDI 4x4 Dies	106
3427	AMAROK Trendline CD 2.0 TDI 4X4 Dies Aut	106
3428	Apolo GL 1.8	106
3429	Apolo GLS/ Vip 1.8	106
3430	Bora 2.0 8v Comfortline Aut.	106
3431	Bora 2.0 8v Comfortline Mec.	106
3432	Bora 2.0/ 2.0 Flex 8v Aut.	106
3433	Bora 2.0/ 2.0 Flex 8v Mec.	106
3434	Caravelle 2.4 Diesel	106
3435	Corrado 2.0 Turbo	106
3436	Corrado G-60 2.8	106
3437	CROSSFOX  1.6 T. Flex 16V 5p	106
3438	CROSSFOX  I MOTION 1.6 T. Flex 16V 5p	106
3439	CROSSFOX 1.6 Mi Total Flex 8V 5p	106
3440	CROSSFOX I MOTION 1.6 Mi T. Flex 8V 5p	106
3441	Delivery Express Turbo Diesel (E6)	106
3442	Delivery Express+ Turbo Diesel	106
3443	EOS Cab. 2.0 Turbo FSI Tiptronic	106
3444	Eurovan 2.4 Diesel	106
3445	Fox 1.0 Mi Total Flex 8V 3p	106
3446	Fox 1.0 Mi Total Flex 8V 5p	106
3447	Fox 1.6 Mi I MOTION Total Flex 8V 5p	106
3448	Fox 1.6 Mi Total Flex 8V 5p	106
3449	Fox BLUEMOTION 1.0 Mi Total Flex 12V 3p	106
3450	Fox BLUEMOTION 1.0 Mi Total Flex 12V 5p	106
3451	Fox BlueMotion 1.6 Mi Total Flex 3p.	106
3452	Fox BlueMotion 1.6 Mi Total Flex 5p.	106
3453	Fox City 1.0 Mi/ 1.0Mi Total Flex 8V 5p	106
3454	Fox City 1.0Mi/ 1.0Mi Total Flex 8V 3p	106
3455	Fox Comfortline 1.0 Flex 12V 5p	106
3456	Fox Comfortline 1.0 Flex 8V 5p	106
3457	Fox Comfortline 1.6 Flex 8V 5p	106
3458	Fox Comfortline I Motion 1.6 Flex 8V 5p	106
3459	Fox Connect 1.6 Flex 8V 5p	106
3460	Fox Connect I Motion 1.6 Flex 8V 5p	106
3461	Fox extreme 1.6 Mi Total Flex 8V 5p	106
3462	Fox Highline I MOTION 1.6 Flex 16V 5p	106
3463	Fox Highline1.6 Flex 16V 5p	106
3464	Fox PEPPER 1.6 Flex 16V 5p	106
3465	Fox PEPPER I MOTION 1.6 Flex 16V 5p	106
3466	Fox Plus 1.0Mi/ 1.0Mi Total Flex 8V 3p	106
3467	Fox Plus 1.0Mi/ 1.0Mi Total Flex 8V 4p	106
3468	Fox Plus 1.6Mi/ 1.6Mi Total Flex 8V 3p	106
3469	Fox Plus 1.6Mi/ 1.6Mi Total Flex 8V 4p	106
3470	Fox PRIME/Hghi. IMOTION 1.6 T.Flex 8V 5p	106
3471	Fox PRIME/Higli. 1.6 Total Flex 8V 5p	106
3472	Fox Rock in Rio 1.6 Mi Total Flex 8V 5p	106
3473	Fox Route 1.0 Mi Total Flex 8V 3p	106
3474	Fox Route 1.0 Mi Total Flex 8V 5p	106
3475	Fox Route 1.6 Mi Total Flex 8V 3p	106
3476	Fox Route 1.6 Mi Total Flex 8V 5p	106
3477	Fox RUN 1.6 Flex 8V 5p	106
3478	Fox SELEÇÃO 1.0 Total Flex 8V 5p	106
3479	Fox SELEÇÃO 1.6 Total Flex 8V 5p	106
3480	Fox SELEÇÃO IMOTION 1.6 Mi T. Flex 8V 5p	106
3481	Fox Sportline/Sports 1.0 Tot.Flex 8V 4p	106
3482	Fox Sportline/Sports 1.0/1.0 Tot.Flex 3p	106
3483	Fox Sportline/Sports 1.6/1.6 Tot.Flex 3p	106
3484	Fox Sportline/Sports 1.6/1.6 Tot.Flex 4p	106
3485	Fox SUNRISE 1.0 Mi Total Flex 8V 5p	106
3486	Fox TRACK 1.0 Flex 12V 5p	106
3487	Fox Trendline 1.0 Flex 12V 5p	106
3488	Fox Trendline 1.0 Flex 8V 5p	106
3489	Fox Trendline 1.6 Flex 8V 5p	106
3490	Fox Xtreme 1.6 Flex 8V 5p	106
3491	Fusca	106
3492	Fusca 2.0 R-Line TSI 16V Aut.	106
3493	Fusca 2.0 TSI 16V Aut.	106
3494	Fusca 2.0 TSI 16V Mec.	106
3495	Gol (novo) 1.0 Mi Total Flex 8V 2p	106
3496	Gol (novo) 1.0 Mi Total Flex 8V 4p	106
3497	Gol (novo) 1.6 Mi Total Flex 8V 2p	106
3498	Gol (novo) 1.6 Mi Total Flex 8V 4p	106
3499	Gol (novo) 1.6 Power/Highi T.Flex 8v 4P	106
3500	Gol 1.0 Flex 12V 5p	106
3501	Gol 1.0 Mi FUN/ Highway/ Sport 16V  2/4p	106
3502	Gol 1.0 Plus 16v 2p	106
3503	Gol 1.0 Plus 16v 4p	106
3504	Gol 1.0 Plus 8v 2p	106
3505	Gol 1.0 Plus 8v 4p	106
3506	Gol 1.0 Power 16v 76cv 4p	106
3507	Gol 1.0 Total Flex 8V 5p (25 Anos)	106
3508	Gol 1.0 Trend/ Power 8V 2p	106
3509	Gol 1.0 Trend/ Power 8V 4p	106
3510	Gol 1.6 I MOTI.Power/Highli T.Flex 8V 4p	106
3511	Gol 1.6 Mi I MOTION Total Flex 8V 3p	106
3512	Gol 1.6 Mi Plus Total Flex 8V 2p	106
3513	Gol 1.6 Mi Plus Total Flex 8V 4p	106
3514	Gol 1.6 Mi Power Total Flex 8V 4p	106
3515	Gol 1.6 Mi Rallye I MOTION T. Flex 8V 4p	106
3516	Gol 1.6 Mi Rallye Total Flex 8V 4p	106
3517	Gol 1.6 Mi/ 1.6i 2p	106
3518	Gol 1.6 Mi/ Power 1.6 Mi 4p	106
3519	Gol 1.6 MSI Flex 16V 5p Aut.	106
3520	Gol 1.6 MSI Flex 8V 5p	106
3521	Gol 1.8 Mi	106
3522	Gol 1.8 Mi 4p	106
3523	Gol 1.8 Mi Power Total Flex 8V 4p	106
3524	Gol 1.8 Mi Rallye Total Flex 8V 4p	106
3525	Gol 1000 (modelo antigo)	106
3526	Gol 1000 Mi 16V 2p Turbo	106
3527	Gol 1000 Mi 16V 4p Turbo	106
3528	Gol 1000 Mi 16V/ Ouro  2p	106
3529	Gol 1000 Mi 16V/ Ouro 4p	106
3530	Gol 1000 Mi 2p  / 1000i	106
3531	Gol 1000 Mi 4p	106
3532	Gol 1000 Mi Plus 16V 2p e 4p	106
3533	Gol 1000 Mi Plus 8v 2p e 4p	106
3534	Gol 1000i Plus 2p	106
3535	Gol 2.0 Mi 2p	106
3536	Gol 2.0 Mi 4p	106
3537	Gol BLACK 1.0 Mi Total Flex 8V 4p	106
3538	Gol City (Trend) 1.0 Mi Total Flex 8V 2p	106
3539	Gol City (Trend) 1.6 Mi T. Flex 8V 2p	106
3540	Gol City (Trend) 1.6 Mi T.Flex 8V 4p	106
3541	Gol City (Trend)/Titan 1.0 T. Flex 8V 4p	106
3542	Gol City 1.0 Mi 8V 2p	106
3543	Gol City 1.0 Mi 8V 4p	106
3544	Gol City 1.0 Total Flex 12V 2p	106
3545	Gol City 1.0 Total Flex 12V 4P	106
3546	Gol City 1.6 Mi 8V 2p	106
3547	Gol City 1.6 Mi 8V 4p	106
3548	Gol CL 1.6 Mi 2p e 4p	106
3549	Gol CL 1.8 Mi 2p e 4p	106
3550	Gol CLi / CL 1.8	106
3551	Gol CLi / CL/ Copa/ Stones 1.6	106
3552	Gol Comfort. I MOTION 1.6 T. Flex 8V 3p	106
3553	Gol Comfort. I MOTION 1.6 T. Flex 8V 5p	106
3554	Gol Comfortline 1.0 T. Flex 12V 5p	106
3555	Gol Comfortline 1.0 T. Flex 8V 3p	106
3556	Gol Comfortline 1.0 T. Flex 8V 5p	106
3557	Gol Comfortline 1.6 T. Flex 8V 3p	106
3558	Gol Comfortline 1.6 T. Flex 8V 5p	106
3559	Gol COPA 1.0 Mi Total Flex 8V 4p	106
3560	Gol COPA 1.6 Mi Total Flex 8V 4p	106
3561	Gol ECOMOTION  1.0 Mi Total Flex 8V 4p	106
3562	Gol ECOMOTION 1.0 Mi Total Flex 8V 2p	106
3563	Gol Furgao 1.0 mi	106
3564	Gol Furgão 1.6 Mi/ 1.6i/ 1.6	106
3565	Gol GL 1.6 Mi/Star 1.6 e 1.8/Atlanta 1.6	106
3566	Gol GL 1.8 Mi 2p e 4p	106
3567	Gol GLi / GL/ Atlanta 1.8	106
3568	Gol GLS 2.0 Mi	106
3569	Gol GT/GTS 1.8	106
3570	Gol GTi 2.0	106
3571	Gol GTi 2000 16V	106
3572	Gol I MOTION 1.6 Mi Total Flex 8V 4p	106
3573	Gol L 1.3/ L/ LS/ C/ S/ BX/ Plus 1.6	106
3574	Gol Last Edition 1.0 Flex 12V 5p	106
3575	Gol Plus 1.0 Mi Total Flex 2p	106
3576	Gol Plus 1.0 Mi Total Flex 4p	106
3577	Gol Rallye 1.6 T. Flex 16V 5p	106
3578	Gol Rallye I MOTION 1.6 T. Flex 16V 5p	106
3579	Gol Rock in Rio 1.0 Mi Total Flex 8V 5p	106
3580	Gol SELEÇÃO 1.0 Mi Total Flex 8V 5p	106
3581	Gol SELEÇÃO 1.6 I MOTION T.Flex 8V 5p	106
3582	Gol SELEÇÃO 1.6 Total Flex 8V 5p	106
3583	Gol Special 1.0 Mi 4p	106
3584	Gol Special 1.0 Total Flex 8V 3p	106
3585	Gol Special 1.0 Total Flex 8V 5p	106
3586	Gol Special 1.6 Mi 8V 99cv 2p	106
3587	Gol Special/ Special Xtreme 1.0 Mi 2p	106
3588	Gol TECH 1.0 Mi Total Flex 8V 2p	106
3589	Gol TECH 1.0 Mi Total Flex 8V 4p	106
3590	Gol TRACK 1.0 Mi Total Flex 8V 4p	106
3591	Gol TRACK 1.0 Total Flex 12V 5p	106
3592	Gol Trendline 1.0 T.Flex 12V 3p	106
3593	Gol Trendline 1.0 T.Flex 12V 5p	106
3594	Gol Trendline 1.0 T.Flex 8V 3p	106
3595	Gol Trendline 1.0 T.Flex 8V 5p	106
3596	Gol Trendline 1.6 T.Flex 8V 3p	106
3597	Gol Trendline 1.6 T.Flex 8V 5p	106
3598	Gol Trendline I Motion 1.6 T. Flex 8V 3p	106
3599	Gol Trendline I MOTION 1.6 T. Flex 8V 5p	106
3600	Gol TSi 1.8/ 1.8Mi	106
3601	Gol TSi 2000 2p e 4p	106
3602	Golf  BLACK EDITON 2.0 Mi T. Flex 8V Tip	106
3603	Golf  TECH 1.6 Mi Total Flex 8V 4p	106
3604	Golf 1.6 Mi Total Flex 8V 4p	106
3605	Golf 1.6 Mi Trip/ Sport 101cv 8V	106
3606	Golf 1.6Mi/ 1.6Mi Gener./Black & Silver	106
3607	Golf 1.8 Mi Sport 150cv Turbo Mec/Aut.	106
3608	Golf 2.0/ 2.0 Mi Flex Aut/Tiptronic.	106
3609	Golf 2.0/ 2.0 Mi Flex Comfortline Aut.	106
3610	Golf 2.0/ 2.0 Mi Flex Comfortline/ Sport	106
3611	Golf 2.0/2.0 T. Flex Mec.(Black & Silv)	106
3612	Golf Comfort. 200 TSI 1.0 Flex 12V Aut.	106
3613	Golf Comfortline 1.0 TSI Total Flex Mec.	106
3614	Golf Comfortline 1.4 TSI 140cv Aut.	106
3615	Golf Comfortline 1.4 TSI 140cv Mec.	106
3616	Golf Comfortline 1.6 MSI Total Flex Aut.	106
3617	Golf Comfortline 1.6 MSI Total Flex Mec.	106
3618	Golf Flash 1.6 Mi/1.6 Mi Tot. Flex 8V 4p	106
3619	Golf GL 1.8/ 2.0i 4p	106
3620	Golf GLX 2.0 4p	106
3621	Golf GT 2.0 Mi T. Flex 8V 4p Tiptronic	106
3622	Golf GT 2.0 Mi Total Flex 8V 4p	106
3623	Golf GTE TSI 1.4 16V Híbrido Aut.	106
3624	Golf GTi 1.8 Mi 180/193cv Turbo 4p Mec.	106
3625	Golf GTi 1.8 Mi 180/193cv Turbo 4p Tip.	106
3626	Golf GTi 1.8 Mi 20V 2p Turbo Mec.	106
3627	Golf GTi 1.8 Mi 20V Turbo 2p Aut.	106
3628	Golf GTi 1.8 Mi 20V Turbo 4p Aut.	106
3629	Golf GTi 1.8 Mi 20V Turbo 4p Mec.	106
3630	Golf GTI 1.8 Turbo	106
3631	Golf GTi 2.0	106
3632	Golf GTi 2.0 TSI 220cv Aut.	106
3633	Golf GTi 350 TSI 2.0 230cv 16V Aut.	106
3634	Golf GTi Cabrio 2.0 Mi	106
3635	Golf GTI VR6/ Golf 2.8 VR6	106
3636	Golf Highline 1.4 TSI 140cv Aut.	106
3637	Golf Highline 1.4 TSI 140cv Mec.	106
3638	Golf Highline 1.4 TSI Total Flex Aut.	106
3639	Golf Highline 1.4 TSI Total Flex Mec.	106
3640	Golf Highline 250 TSI 1.4 Flex 16V Aut.	106
3641	Golf SILVER EDIT. 2.0 Mi T.Flex 8v Mec.	106
3642	Golf SILVER EDIT. 2.0 Mi T.Flex 8V Tip.	106
3643	Golf Sportline 1.6 Mi Total Flex 8V 4p	106
3644	Golf Sportline 2.0 Mi Total F. 8V Tip.	106
3645	Golf Variant Comf. 250 1.4 TSI Flex Aut.	106
3646	Golf Variant Comfort. 1.4 TSI T.Flex Aut	106
3647	Golf Variant Comfortline 1.4 TSI  Aut.	106
3648	Golf Variant Comfortline 1.4 TSI Mec.	106
3649	Golf Variant High. 250 1.4 TSI Flex Aut.	106
3650	Golf Variant Highli. 1.4 TSI T.Flex Aut	106
3651	Golf Variant Highline 1.4 TSI Aut.	106
3652	Grand Saveiro Xtreme/Street  1.6/1.8/2.0	106
3653	JETTA  GLX III 2.8 VR6	106
3654	JETTA 2.5 20V 150/170cv Tiptronic	106
3655	JETTA 250 TSI 1.4 flex 16v Aut.	106
3656	JETTA Comfort. 250 TSI 1.4 Flex 16v Aut.	106
3657	JETTA Comfortline  2.0 T.Flex 8V 4p Mec.	106
3658	JETTA Comfortline 1.4 TSI 16V 4p Aut.	106
3659	JETTA Comfortline 2.0 T.Flex 8V 4p Tipt.	106
3660	JETTA GLI 350 TSI 2.0 16V 4p Aut.	106
3661	JETTA Highline 2.0 TSI 16V 4p Tiptronic	106
3662	JETTA R-Line 250 TSI 1.4 Flex 16V Aut.	106
3663	JETTA Trendline 1.4 TSI 16V 4p  Aut.	106
3664	JETTA Trendline 1.4 TSI 16V 4p Mec.	106
3665	JETTA Trendline 2.0 T.Flex 8V 4p Tip.	106
3666	JETTA Variant 2.5 20V 170cv Tiptronic	106
3667	Kombi Carat	106
3668	Kombi Escolar 1.6 MPi	106
3669	Kombi Escolar/50 anos 1.4 Mi Total Flex	106
3670	Kombi Furgão	106
3671	Kombi Furgão 1.4 Mi Total Flex 8V	106
3672	Kombi Furgão Diesel	106
3673	Kombi LAST EDITION 56 1.4 Mi Total Flex	106
3674	Kombi Lotação 1.4 Mi Total Flex 8V	106
3675	Kombi Lotação 1.6 MPi	106
3676	Kombi Pick-Up	106
3677	Kombi Pick-Up Diesel	106
3678	Kombi Standard 1.4 Mi Total Flex 8V	106
3679	Kombi Standard/ Luxo/ Série Prata	106
3680	Logus 1.6 / CLi / CL/ GL	106
3681	Logus 1.8 / CLi / CL	106
3682	Logus GLi / GL 1.8	106
3683	Logus GLS 1.8	106
3684	Logus GLSi / GLS 2000	106
3685	Logus Wolfsburg Edition 2000i	106
3686	New Beetle 2.0 Mi Mec./Aut.	106
3687	Nivus Comfortline 1.0 200 TSI Flex Aut.	106
3688	Nivus GTS 1.4 250 TSI Flex Aut.	106
3689	Nivus Highline 1.0 200 TSI Flex Aut.	106
3690	Nivus Launching Ed. 1.0 200 TSI Flex Aut	106
3691	Nivus Sense 1.0 200 TSI Flex Aut.	106
3692	Parati 1.0 Mi FUN/ SunSet 16V 4p	106
3693	Parati 1.0 Mi Plus 16v 4p	106
3694	Parati 1.0 Mi Summer 16v 4p	106
3695	Parati 1.0 Mi Tour 16V 76cv 4p	106
3696	Parati 1.6 Mi Plus Total Flex  8V 4p	106
3697	Parati 1.6 Mi/ 1.6 Mi City	106
3698	Parati 1.6Mi/1.6Mi City/T.Field T.Flex	106
3699	Parati 1.8 Mi City Total Flex 8V 4p	106
3700	Parati 1.8 Mi CROSSOVER Total Flex 8V 4p	106
3701	Parati 1.8 Mi Plus Total Flex 8V 4p	106
3702	Parati 1.8 Mi T. Field Total Flex 8V 4p	106
3703	Parati 1.8 Mi Tour 8V 99cv 4p	106
3704	Parati 1.8 Mi/ 1.8 Mi Plus	106
3705	Parati 1000 Mi 16V 2p e 4p	106
3706	Parati 1000 Mi 16V 4p Turbo	106
3707	Parati 2.0 Mi Tour 8V 112cv 4p	106
3708	Parati 2.0 Mi/ 2.0 Mi Track & Field	106
3709	Parati C 1.6/ CL 1.6 Mi 2p e 4p	106
3710	Parati CL 1.8 Mi 2p e 4p	106
3711	Parati CLi / CL/ Atlanta 1.6	106
3712	Parati CLi / CL/ Atlanta 1.8	106
3713	Parati COMFORTLINE 1.6 Mi Tot.Flex 8V 4p	106
3714	Parati COMFORTLINE 1.8 Mi Tot.Flex 8V 4p	106
3715	Parati CROSSOVER 2.0 8V/ 1.0 16V TB 4p	106
3716	Parati Evidence 1.8 8V/ 1.0 16V TB 4p	106
3717	Parati GL 1.6 Mi/ 1.6/ GLS/ Club 1.6	106
3718	Parati GL 1.8 Mi/ Club 1.8 Mi 2p e 4p	106
3719	Parati GLi / GL 1.8	106
3720	Parati GLS 2.0 Mi 2/4p	106
3721	Parati GLSi 2.0 / GLS/ Surf 1.8	106
3722	Parati GTi 2.0 Mi 16V	106
3723	Parati Plus/ LS/ S	106
3724	Parati SURF 1.6 Mi Total Flex	106
3725	Parati SURF 1.8 Mi Total Flex	106
3726	Parati TITAN 1.6 Mi Total Flex 8V 4p	106
3727	Parati Utility 1.8 8V/ 1.0 Turbo 16V	106
3728	Passat  L/LS/LSe/GL/GLS/TS/Fla/Vill/Plus	106
3729	Passat 1.8 Aut.	106
3730	Passat 1.8 Mec.	106
3731	Passat 1.8 Tiptronic	106
3732	Passat 2.0	106
3733	Passat 2.0 FSI Tiptronic	106
3734	Passat 2.8 V6 Mec.	106
3735	Passat 2.8 V6 Protect Tiptronic	106
3736	Passat 2.8 V6 Tiptronic	106
3737	Passat 3.2 V6 FSI 24V 250cv Tip.	106
3738	Passat CC 2.0 TSI 211cv Tiptronic	106
3739	Passat CC 3.6 V6 FSI 300cv Tiptronic	106
3740	Passat Comfortline 2.0 TSI 220cv Tip.	106
3741	Passat Highline 2.0 TSI 220cv Tip.	106
3742	Passat Pointer GTS	106
3743	Passat R-Line TB 2.0 TSI Tiptronic 4p	106
3744	Passat TB 2.0 FSI/TSI 211cv Tiptronic 4p	106
3745	Passat Turbo 1.8 Mec.	106
3746	Passat Turbo 1.8 Tiptronic	106
3747	Passat Variant  2.0 FSI 150cv Tiptron.5p	106
3748	Passat Variant 1.8 Aut.	106
3749	Passat Variant 1.8 Mec.	106
3750	Passat Variant 2.0	106
3751	Passat Variant 2.8 V6	106
3752	Passat Variant 2.8 V6 Tiptronic	106
3753	Passat Variant 3.2 V6 FSI 24V 250cv Tip.	106
3754	Passat Variant R-Line TB 2.0 TSI Tip. 5p	106
3755	Passat Variant Turbo 1.8	106
3756	Passat Variant Turbo 1.8 Tiptronic	106
3757	Passat Variant Turbo 2.0 FSI Tiptron. 5p	106
3758	Passat Variant VR6 2.8	106
3759	Passat VR6 2.8	106
3760	Pointer 1.8 / CLi	106
3761	Pointer GLi 1.8	106
3762	Pointer GLi 2.0	106
3763	Pointer GTi 2.0	106
3764	Polo 1.0 Flex 12V 5p	106
3765	Polo 1.0 Mi 79cv 16V 5p	106
3766	Polo 1.0 MPI Flex 12V 5p	106
3767	Polo 1.0 TSI Flex 12V 5p	106
3768	Polo 1.6 E-Flex 8V 5p	106
3769	Polo 1.6 Mi/ S.Ouro 1.6Mi 101cv 8V 5p	106
3770	Polo 1.6 Mi/S.Ouro 1.6 Mi Tot.Flex 8V 5p	106
3771	Polo 1.6 MSI Flex 16V 5p	106
3772	Polo 1.6 MSI Total Flex 16V 5p Aut.	106
3773	Polo 2.0 Mi 116cv 8V 5p	106
3774	Polo BLUEMOTION 1.6 Total Flex 8V 5p	106
3775	Polo Classic 1.0 Mi 16v  65cv 4p	106
3776	Polo Classic/ Special 1.8 Mi	106
3777	Polo Comfort. 200 TSI 1.0 Flex 12V Aut.	106
3778	Polo Comfortline TSI 1.0 Flex 12V Aut.	106
3779	Polo GT 2.0 Mi Total Flex 8V 5p	106
3780	Polo GTI 1.8 Mi 150cv 20V Turbo 3p	106
3781	Polo GTS 1.4 TSI 16V Flex	106
3782	Polo Highline 200 TSI 1.0 Flex 12V Aut.	106
3783	Polo Highline TSI 1.0 Flex 12V Aut.	106
3784	Polo I MOTION 1.6 Total Flex  5p	106
3785	Polo Next 1.6 Mi 101cv 8V 5p	106
3786	Polo Robust 1.0 Flex 12V 5p	106
3787	Polo Sed. COMFORT. 1.6 Mi Tot. Flex 8v	106
3788	Polo Sed./Sed. COMF. 2.0/2.0 Flex 8V 4p	106
3789	Polo Sed.COMFORT. I MOTION 1.6 T.Flex 4p	106
3790	Polo Sedan 1.6 Mi 101cv 8V 4p	106
3791	Polo Sedan 1.6 Mi Total Flex 8V 4p	106
3792	Polo Sedan Evidence 1.6 Mi T.Flex 8v 4p	106
3793	Polo Sedan I MOTION  1.6 Total Flex  4p	106
3794	Polo Sense TSI 1.0 Flex 12V Aut	106
3795	Polo SPORTLINE 1.6 Mi Total Flex 8V 5p	106
3796	Polo Sportline 2.0 Mi Total Flex 8V 5p	106
3797	Polo SPORTLINE I MOTION 1.6 T.Flex 5p	106
3798	Polo Track 1.0 Flex 12V 5p	106
3799	Polo Track First Edition 1.0 Flex 12V 5p	106
3800	Polo Track Rock in Rio 1.0 Flex 12V 5p	106
3801	Quantum 1.8 Mi/ 1.8i	106
3802	Quantum 2.0 Mi	106
3803	Quantum CLi / CL / C/ CS/ CD/ CG 1.8/2.0	106
3804	Quantum Evidence 2.0 Mi	106
3805	Quantum Exclusive 2.0 Mi	106
3806	Quantum GLi / GL 1.8/ 2.0	106
3807	Quantum GLSi / GLS 1.8/Sport/ Family 2.0	106
3808	Santana 1.8 Mi	106
3809	Santana 2.0 Mi 2p e 4p	106
3810	Santana CLi /CL /C 1.8/2.0 /SU 2.0 2p/4p	106
3811	Santana COMFORTLINE 1.8 Mi 8V 4p	106
3812	Santana CS/CD/CG	106
3813	Santana Evidenc 2.0 MI	106
3814	Santana Exclusiv 2.0 Mi/ Executivo 2.0i	106
3815	Santana GLi / GL/ Sport 1.8/ 2.0	106
3816	Santana GLSi / GLS 1.8/ 2.0	106
3817	Saveiro 1.6 Mi Total Flex 8V CE	106
3818	Saveiro 1.6 Mi/ 1.6 Mi Total Flex 8V	106
3819	Saveiro 1.6 Mi/ 1.6Mi City Total Flex 8V	106
3820	Saveiro 1.8 Mi	106
3821	Saveiro 2.0 Mi	106
3822	Saveiro City 1.8 Mi Total Flex 8V	106
3823	Saveiro CL 1.6 Mi / CL/ C 1.6	106
3824	Saveiro CL/ Summer 1.8 Mi e 1.8	106
3825	Saveiro CROSS 1.6 Mi Total Flex 8V CE	106
3826	Saveiro CROSS 1.6 T. Flex 16V CE	106
3827	Saveiro CROSS 1.6 T.Flex 16V CD	106
3828	Saveiro CROSSOVER 1.6 Mi Total Flex 8V	106
3829	Saveiro CROSSOVER 1.8 Mi 8V	106
3830	Saveiro CROSSOVER 1.8 Mi Total Flex 8V	106
3831	Saveiro Diesel (todas)	106
3832	Saveiro Extreme 1.6 Flex 16V CD	106
3833	Saveiro FUN 1.8 99cv/ City e S.Surf  1.6	106
3834	Saveiro GL 1.8Mi e 1.6/GL/LS/S/ Sunset	106
3835	Saveiro Highline 1.6 T. Flex 8V CD	106
3836	Saveiro Pepper 1.6 Flex 8V CD	106
3837	Saveiro Pepper 1.6 Flex 8V CE	106
3838	Saveiro Robust 1.6 Total Flex 16V 	106
3839	Saveiro Robust 1.6 Total Flex 16V CD	106
3840	Saveiro Robust 1.6 Total Flex 8V	106
3841	Saveiro Robust 1.6 Total Flex 8V CD	106
3842	Saveiro Rock in Rio 1.6 Total Flex 8V CD	106
3843	Saveiro SPORTLINE 1.6 Mi Total Flex 8V	106
3844	Saveiro SPORTLINE 1.8 Mi Total Flex 8V	106
3845	Saveiro Startline 1.6 T.Flex 8V	106
3846	Saveiro Super Surf  1.8 Mi 8V 99cv	106
3847	Saveiro Super Surf 1.6 Mi Total Flex 8V	106
3848	Saveiro Super Surf 1.8 Mi Total Flex 8V	106
3849	Saveiro SURF 1.6 Mi Total Flex 2p	106
3850	Saveiro SURF 1.8 Mi Total Flex 2p	106
3851	Saveiro TITAN  1.6 Mi Total Flex 2p	106
3852	Saveiro Trendline 1.6 T.Flex 8V	106
3853	Saveiro Trendline 1.6 T.Flex 8V CD	106
3854	Saveiro Trendline 1.6 T.Flex 8V CE	106
3855	Saveiro Trendline 1.6 Total Flex 16V	106
3856	Saveiro TROOPER 1.6 Mi Total Flex 8V	106
3857	Saveiro TROOPER 1.6 Mi Total Flex 8V CE	106
3858	Saveiro TSi 2.0 Mi	106
3859	SpaceCross 1.6 Mi Total Flex 16V	106
3860	SpaceCross 1.6 Mi Total Flex 8V	106
3861	SpaceCross I MOTION 1.6 Mi T. Flex 16V	106
3862	SpaceCross I MOTION 1.6 Mi Total Flex 8V	106
3863	SPACEFOX  SPORTLINE/HIGHLINE 1.6 T.Flex	106
3864	SPACEFOX  TREND I MOTION 1.6 T. Flex 8V	106
3865	SPACEFOX 1.6 Trendline I MOT. T.Flex 8V	106
3866	SPACEFOX 1.6 Trendline Total Flex 8v 5p	106
3867	SPACEFOX 1.6/ 1.6 Trend Total Flex 8V 5p	106
3868	SPACEFOX COMF. I MOTION 1.6 Flex 8V 5p	106
3869	SPACEFOX COMFORTLINE 1.6 Mi T.Flex 8V 5p	106
3870	SPACEFOX HIGHLINE 1.6 T.Flex 16V	106
3871	SPACEFOX HIGHLINE I MOT. 1.6 T.Flex 16V	106
3872	SPACEFOX Route 1.6 Mi T.Flex 5p	106
3873	SPACEFOX SPORTLINE/HIGHLINE I MOTION 1.6	106
3874	TAOS Comfortline 1.4 250 TSI Flex Aut.	106
3875	TAOS Highline 1.4 250 TSI Flex Aut.	106
3876	TAOS Launching Ed. 1.4 250 TSI Flex Aut.	106
3877	T-Cross 1.0 TSI Flex 12V 5p Mec.	106
3878	T-Cross 200 TSI 1.0  Flex 12V 5p Aut.	106
3879	T-Cross Comfor. 200 TSI 1.0 Flex 5p Aut.	106
3880	T-Cross Ext. 250 TSI 1.4 Flex 16V 5p Aut	106
3881	T-Cross Hig. 250 TSI 1.4 Flex 16V 5p Aut	106
3882	T-Cross Sense 200 TSI 1.0 Flex 5p Aut.	106
3883	Tera 1.0 170 TSI Flex 12V 5p Mec.	106
3884	Tera 1.0 MPI Flex 12V 5p Mec.	106
3885	Tera Comfort 1.0 170 TSI Flex 12V 5p Aut	106
3886	Tera High 1.0 170 TSI Flex 12V 5p Aut	106
3887	TIGUAN 1.4 TSI 16V 150cv 5p	106
3888	TIGUAN 2.0 TSI 16V 200cv Tiptronic 5p	106
3889	TIGUAN Allspac 250 TSI 1.4 Flex	106
3890	TIGUAN Allspac Comf 250 TSI 1.4 Flex	106
3891	TIGUAN Allspac R-Line 300 TSI 2.0 	106
3892	TIGUAN Allspac R-Line 350 TSI 2.0 4x4	106
3893	TOUAREG 3.2 24V V6 Tiptronic 5p	106
3894	TOUAREG 3.6 24V V6 280cv Tiptronic 5p	106
3895	TOUAREG 4.2 32V V8  Tiptronic 5p	106
3896	TOUAREG R-Line 4.2 V8 360cv Tiptronic 5p	106
3897	up! 1.0 Total Flex 12V 5p	106
3898	up! black/white/red 1.0 T. Flex 12V 5p	106
3899	up! black/white/red 1.0 TSI TFlex 12V 5p	106
3900	up! black/white/red I MOTION 1.0 Flex 5p	106
3901	up! Connect 1.0 TSI Total Flex 12V 5p	106
3902	up! cross 1.0 T. Flex 12V 5p	106
3903	up! cross 1.0 TSI Total Flex 12V 5p	106
3904	up! cross I MOTION 1.0 T.Flex 12V 5p	106
3905	up! high 1.0 Total Flex 12V 5p	106
3906	up! high 1.0 TSI Total Flex 12V 5p	106
3907	up! high I MOTION 1.0 T. Flex 12V 5p	106
3908	up! move 1.0 T. Flex 12V 3p	106
3909	up! move 1.0 Total Flex 12V 5p	106
3910	up! move 1.0 TSI Total Flex 12V 5p	106
3911	up! move I MOTION 1.0 T. Flex 12V 3p	106
3912	up! move I MOTION 1.0 T. Flex 12V 5p	106
3913	up! Pepper 1.0 TSI T.Flex 12V 5p	106
3914	up! Run 1.0 Total Flex 12V 5p	106
3915	up! Run I MOTION 1.0 Total Flex 12V 5p	106
3916	up! SPEED 1.0 TSI T. Flex 12V 5p	106
3917	up! take 1.0 T. Flex 12V 3p	106
3918	up! take 1.0 Total Flex 12V 5p	106
3919	up! track 1.0 Total Flex 12V 5p	106
3920	up! Xtreme 1.0 TSI Total Flex 12V 5p	106
3921	Van 1.6 Mi (furgão)	106
3922	VIRTUS 1.6 MSI Flex 16V 4p Aut.	106
3923	VIRTUS 1.6 MSI Flex 16V 5p Mec.	106
3924	VIRTUS Comfort. 200 TSI 1.0 Flex 12V Aut	106
3925	VIRTUS Exclusive 250TSI 1.4 Flex 16V Aut	106
3926	VIRTUS GTS 1.4 TSI 16V Flex 4p	106
3927	VIRTUS Highline 200 TSI 1.0 Flex 12V Aut	106
3928	VIRTUS Sense 1.0 Flex 12V 5p Mec. 	106
3929	VIRTUS Sense 1.6 Flex 16V 5p Aut. 	106
3930	VIRTUS TSI 1.0 Flex 12V 4p Aut.	106
3931	VIRTUS TSI 1.0 Flex 12V 4p Mec.	106
3932	VOYAGE  Trendline 1.0 T.Flex 8V 4p	106
3933	VOYAGE 1.0 Flex 12V 4p	106
3934	VOYAGE 1.0/1.0 City Mi Total Flex 8V 4p	106
3935	VOYAGE 1.6 MSI Flex 16V 4p Aut.	106
3936	VOYAGE 1.6 MSI Flex 8V 4p	106
3937	VOYAGE 1.6/1.6 City  Mi Total Flex 8V 4p	106
3938	VOYAGE C/CL/Fox 1.6	106
3939	VOYAGE CL 1.8	106
3940	VOYAGE COMF/Highli. 1.6 T.Flex 8V 4p	106
3941	VOYAGE Comfortline  1.0 T.Flex 8V 4p	106
3942	VOYAGE Comfortline 1.0 T.Flex 12V 4p	106
3943	VOYAGE Evidence 1.6 Total Flex 8V 4p	106
3944	VOYAGE GL 1.8 4p (Argentino)	106
3945	VOYAGE GL/ Special 1.6/ 1.8	106
3946	VOYAGE I MOTION  Trendline 1.6 T.Flex 8V	106
3947	VOYAGE I MOTION 1.6 Mi Total Flex 8V	106
3948	VOYAGE I MOTION COMF/Hghli.1.6 T.Flex 8V	106
3949	VOYAGE I MOTION Evidence 1.6 T.Flex 8V	106
3950	VOYAGE I MOTION TREND 1.6 Mi T. Flex 8V	106
3951	VOYAGE L/LS/Plus/GLS/S/Sport/Super L.Ang	106
3952	VOYAGE SELEÇÃO 1.0 Mi Total Flex 8V 4p	106
3953	VOYAGE SELEÇÃO 1.6 I MOTION T.Flex 8V 4p	106
3954	VOYAGE SELEÇÃO 1.6 Total Flex 8V 4p	106
3955	VOYAGE TREND 1.6 Mi Total Flex 8V 4p	106
3956	VOYAGE Trendline 1.0 T.Flex 12V 4p	106
3957	VOYAGE Trendline 1.6 T.Flex 8V 4p	106
\.


--
-- Data for Name: opcional; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.opcional (id, nome) FROM stdin;
1	Ar condicionado
2	Direção hidráulica
3	Direção elétrica
4	Vidro elétrico
5	Trava elétrica
6	Airbag
7	ABS
8	Multimídia
9	Bluetooth
10	Câmera de ré
11	Sensor de estacionamento
12	Banco de couro
13	Teto solar
14	Rodas de liga leve
15	Piloto automático
\.


--
-- Data for Name: permissoes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.permissoes (id, chave) FROM stdin;
1	veiculo.criar
2	veiculo.editar
3	veiculo.excluir
4	veiculo.visualizar
6	venda.visualizar
7	dashboard.visualizar
9	usuario.editar
8	plano.editar
5	venda.criar
10	usuario.visualizar
11	usuario.criar
12	usuario.excluir
13	loja.visualizar
14	loja.criar
15	loja.editar
16	loja.excluir
17	lead.visualizar
18	lead.criar
19	lead.editar
20	lead.excluir
21	permissao.visualizar
22	permissao.criar
23	permissao.editar
24	permissao.excluir
25	plano.visualizar
26	loja.trocar
27	venda.cancelar
\.


--
-- Data for Name: plano; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.plano (id, nome, preco, limite_veiculos, ativo, destaque) FROM stdin;
2	PRO	99.90	50	t	1
3	PREMIUM	199.90	200	t	2
1	FREE	0.00	10	t	0
\.


--
-- Data for Name: plano_consumo_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.plano_consumo_log (id, loja_id, veiculo_id, acao, criado_em) FROM stdin;
\.


--
-- Data for Name: role_permissao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_permissao (role_id, permissao_id) FROM stdin;
4	7
4	17
4	13
4	25
4	10
4	4
4	6
4	27
2	27
2	1
2	2
2	3
2	4
2	5
2	6
2	7
2	9
2	10
2	11
2	13
2	14
2	15
2	16
2	17
2	25
2	26
2	12
1	1
1	2
1	3
1	4
1	5
1	6
1	7
1	8
1	9
1	18
1	19
1	20
1	17
1	14
1	15
1	16
1	13
1	22
1	23
1	24
1	21
1	25
1	11
1	12
1	10
1	26
3	4
3	5
3	6
3	7
3	17
3	13
3	25
3	26
3	27
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, nome) FROM stdin;
1	MASTER
4	FINANCEIRO
2	ADMIN
3	VENDEDOR
\.


--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuario (id, empresa_id, nome, email, senha, tipo, ativo, data_cadastro, master) FROM stdin;
1	1	Administrador	admin@mfs.com	$2b$10$8Qz0k5Zp3x2vQ0lFZyQy8OqXl0W6Fq2r8Q0zJ6l2x6zQ8lW8r8m5G	admin	t	2026-05-02 21:01:26.796467	t
\.


--
-- Data for Name: usuario_loja; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuario_loja (id, usuario_id, loja_id, ativo, perfil) FROM stdin;
\.


--
-- Data for Name: usuario_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuario_role (usuario_id, role_id, loja_id, id) FROM stdin;
\.


--
-- Data for Name: veiculo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.veiculo (id, empresa_id, marca, modelo, cor, quilometragem, combustivel, valor, descricao, status, data_cadastro, video_url, destaque, versao, cambio, carroceria, final_placa, aceita_troca, licenciado, codigo_interno, placa, renavam, chassi, ano_modelo, tipo_compra, preco_compra, percentual_comissao, valor_comissao, data_entrada, loja_id, slug, busca) FROM stdin;
\.


--
-- Data for Name: veiculo_documento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.veiculo_documento (id, veiculo_id, proprietario_id, tipo, arquivo, created_at, loja_id) FROM stdin;
\.


--
-- Data for Name: veiculo_foto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.veiculo_foto (id, veiculo_id, url, principal, empresa_id, loja_id) FROM stdin;
\.


--
-- Data for Name: veiculo_midia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.veiculo_midia (id, veiculo_id, empresa_id, loja_id, tipo, url, principal, ordem, created_at) FROM stdin;
\.


--
-- Data for Name: veiculo_opcional; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.veiculo_opcional (id, veiculo_id, opcional_id, loja_id) FROM stdin;
\.


--
-- Data for Name: veiculo_proprietario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.veiculo_proprietario (id, veiculo_id, nome, cpf_cnpj, telefone, email, endereco, created_at, loja_id) FROM stdin;
\.


--
-- Data for Name: veiculo_view; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.veiculo_view (id, veiculo_id, loja_id, ip, user_agent, created_at) FROM stdin;
\.


--
-- Data for Name: venda; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.venda (id, veiculo_id, empresa_id, data_venda, nome_comprador, cpf_comprador, telefone_comprador, condicao_pagamento, parcelas, banco_financiamento, valor_venda, observacoes, status, motivo_cancelamento, loja_id, vendedor, rg_comprador, estado, cidade, bairro, endereco, numero, complemento, cep, email, profissao, data_nasc, renda, valor_entrada, valor_parcela) FROM stdin;
\.


--
-- Data for Name: venda_entrada; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.venda_entrada (id, venda_id, empresa_id, loja_id, marca, modelo, tipo, ano_modelo, renavam, chassi, placa, cor, numero_motor, combustivel, potencia, km, valor_entrada, created_at) FROM stdin;
\.


--
-- Data for Name: versao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.versao (id, nome, modelo_id, codigo_fipe) FROM stdin;
\.


--
-- Name: assinatura_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.assinatura_id_seq', 1, false);


--
-- Name: avaliacao_loja_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.avaliacao_loja_id_seq', 1, false);


--
-- Name: empresa_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.empresa_id_seq', 1, true);


--
-- Name: favorito_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.favorito_id_seq', 1, false);


--
-- Name: lead_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lead_id_seq', 1, false);


--
-- Name: loja_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.loja_id_seq', 1, false);


--
-- Name: loja_plano_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.loja_plano_id_seq', 54, true);


--
-- Name: marca_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.marca_id_seq', 109, true);


--
-- Name: menus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.menus_id_seq', 7, true);


--
-- Name: modelo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.modelo_id_seq', 3957, true);


--
-- Name: opcional_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.opcional_id_seq', 15, true);


--
-- Name: permissoes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.permissoes_id_seq', 27, true);


--
-- Name: plano_consumo_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.plano_consumo_log_id_seq', 43, true);


--
-- Name: plano_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.plano_id_seq', 3, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 4, true);


--
-- Name: usuario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_id_seq', 1, false);


--
-- Name: usuario_loja_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_loja_id_seq', 98, true);


--
-- Name: usuario_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_role_id_seq', 15, true);


--
-- Name: veiculo_documento_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.veiculo_documento_id_seq', 12, true);


--
-- Name: veiculo_foto_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.veiculo_foto_id_seq', 140, true);


--
-- Name: veiculo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.veiculo_id_seq', 1, false);


--
-- Name: veiculo_midia_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.veiculo_midia_id_seq', 1, false);


--
-- Name: veiculo_opcional_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.veiculo_opcional_id_seq', 448, true);


--
-- Name: veiculo_proprietario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.veiculo_proprietario_id_seq', 73, true);


--
-- Name: veiculo_view_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.veiculo_view_id_seq', 1, false);


--
-- Name: venda_entrada_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.venda_entrada_id_seq', 71, true);


--
-- Name: venda_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.venda_id_seq', 1, false);


--
-- Name: versao_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.versao_id_seq', 1, false);


--
-- Name: assinatura assinatura_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assinatura
    ADD CONSTRAINT assinatura_pkey PRIMARY KEY (id);


--
-- Name: avaliacao_loja avaliacao_loja_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avaliacao_loja
    ADD CONSTRAINT avaliacao_loja_pkey PRIMARY KEY (id);


--
-- Name: empresa empresa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empresa
    ADD CONSTRAINT empresa_pkey PRIMARY KEY (id);


--
-- Name: empresa empresa_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empresa
    ADD CONSTRAINT empresa_slug_key UNIQUE (slug);


--
-- Name: favorito favorito_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorito
    ADD CONSTRAINT favorito_pkey PRIMARY KEY (id);


--
-- Name: favorito favorito_usuario_id_veiculo_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorito
    ADD CONSTRAINT favorito_usuario_id_veiculo_id_key UNIQUE (usuario_id, veiculo_id);


--
-- Name: lead lead_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead
    ADD CONSTRAINT lead_pkey PRIMARY KEY (id);


--
-- Name: loja loja_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loja
    ADD CONSTRAINT loja_pkey PRIMARY KEY (id);


--
-- Name: loja_plano loja_plano_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loja_plano
    ADD CONSTRAINT loja_plano_pkey PRIMARY KEY (id);


--
-- Name: loja loja_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loja
    ADD CONSTRAINT loja_slug_key UNIQUE (slug);


--
-- Name: marca marca_nome_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marca
    ADD CONSTRAINT marca_nome_key UNIQUE (nome);


--
-- Name: marca marca_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marca
    ADD CONSTRAINT marca_pkey PRIMARY KEY (id);


--
-- Name: menus menus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_pkey PRIMARY KEY (id);


--
-- Name: modelo modelo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modelo
    ADD CONSTRAINT modelo_pkey PRIMARY KEY (id);


--
-- Name: opcional opcional_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opcional
    ADD CONSTRAINT opcional_pkey PRIMARY KEY (id);


--
-- Name: permissoes permissoes_chave_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissoes
    ADD CONSTRAINT permissoes_chave_key UNIQUE (chave);


--
-- Name: permissoes permissoes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissoes
    ADD CONSTRAINT permissoes_pkey PRIMARY KEY (id);


--
-- Name: plano_consumo_log plano_consumo_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plano_consumo_log
    ADD CONSTRAINT plano_consumo_log_pkey PRIMARY KEY (id);


--
-- Name: plano plano_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plano
    ADD CONSTRAINT plano_pkey PRIMARY KEY (id);


--
-- Name: role_permissao role_permissao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissao
    ADD CONSTRAINT role_permissao_pkey PRIMARY KEY (role_id, permissao_id);


--
-- Name: roles roles_nome_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_nome_key UNIQUE (nome);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: loja unique_cnpj; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loja
    ADD CONSTRAINT unique_cnpj UNIQUE (cnpj);


--
-- Name: usuario unique_email_empresa; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT unique_email_empresa UNIQUE (empresa_id, email);


--
-- Name: empresa unique_empresa_email; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empresa
    ADD CONSTRAINT unique_empresa_email UNIQUE (email);


--
-- Name: loja unique_loja_empresa; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loja
    ADD CONSTRAINT unique_loja_empresa UNIQUE (id, empresa_id);


--
-- Name: loja unique_loja_slug; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loja
    ADD CONSTRAINT unique_loja_slug UNIQUE (slug);


--
-- Name: usuario unique_usuario_email; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT unique_usuario_email UNIQUE (email);


--
-- Name: usuario usuario_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_email_key UNIQUE (email);


--
-- Name: usuario_loja usuario_loja_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_loja
    ADD CONSTRAINT usuario_loja_pkey PRIMARY KEY (id);


--
-- Name: usuario_loja usuario_loja_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_loja
    ADD CONSTRAINT usuario_loja_unique UNIQUE (usuario_id, loja_id);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);


--
-- Name: usuario_role usuario_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_role
    ADD CONSTRAINT usuario_role_pkey PRIMARY KEY (id);


--
-- Name: veiculo_documento veiculo_documento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_documento
    ADD CONSTRAINT veiculo_documento_pkey PRIMARY KEY (id);


--
-- Name: veiculo_foto veiculo_foto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_foto
    ADD CONSTRAINT veiculo_foto_pkey PRIMARY KEY (id);


--
-- Name: veiculo_midia veiculo_midia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_midia
    ADD CONSTRAINT veiculo_midia_pkey PRIMARY KEY (id);


--
-- Name: veiculo_opcional veiculo_opcional_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_opcional
    ADD CONSTRAINT veiculo_opcional_pkey PRIMARY KEY (id);


--
-- Name: veiculo veiculo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo
    ADD CONSTRAINT veiculo_pkey PRIMARY KEY (id);


--
-- Name: veiculo_proprietario veiculo_proprietario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_proprietario
    ADD CONSTRAINT veiculo_proprietario_pkey PRIMARY KEY (id);


--
-- Name: veiculo_view veiculo_view_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_view
    ADD CONSTRAINT veiculo_view_pkey PRIMARY KEY (id);


--
-- Name: venda_entrada venda_entrada_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venda_entrada
    ADD CONSTRAINT venda_entrada_pkey PRIMARY KEY (id);


--
-- Name: venda venda_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venda
    ADD CONSTRAINT venda_pkey PRIMARY KEY (id);


--
-- Name: versao versao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.versao
    ADD CONSTRAINT versao_pkey PRIMARY KEY (id);


--
-- Name: versao versao_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.versao
    ADD CONSTRAINT versao_unique UNIQUE (codigo_fipe, modelo_id);


--
-- Name: idx_lead_loja; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_lead_loja ON public.lead USING btree (loja_id);


--
-- Name: idx_lead_veiculo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_lead_veiculo ON public.lead USING btree (veiculo_id);


--
-- Name: idx_midia_loja; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_midia_loja ON public.veiculo_midia USING btree (loja_id);


--
-- Name: idx_midia_veiculo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_midia_veiculo ON public.veiculo_midia USING btree (veiculo_id);


--
-- Name: idx_usuario_loja_loja; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_usuario_loja_loja ON public.usuario_loja USING btree (loja_id);


--
-- Name: idx_usuario_loja_usuario; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_usuario_loja_usuario ON public.usuario_loja USING btree (usuario_id);


--
-- Name: idx_veiculo_busca; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_veiculo_busca ON public.veiculo USING gin (busca);


--
-- Name: idx_veiculo_empresa; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_veiculo_empresa ON public.veiculo USING btree (empresa_id);


--
-- Name: idx_veiculo_loja; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_veiculo_loja ON public.veiculo USING btree (loja_id);


--
-- Name: idx_veiculo_loja_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_veiculo_loja_status ON public.veiculo USING btree (loja_id, status);


--
-- Name: idx_veiculo_slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_veiculo_slug ON public.veiculo USING btree (slug);


--
-- Name: idx_veiculo_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_veiculo_status ON public.veiculo USING btree (status);


--
-- Name: idx_venda_data; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_venda_data ON public.venda USING btree (data_venda DESC);


--
-- Name: idx_venda_loja; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_venda_loja ON public.venda USING btree (loja_id);


--
-- Name: idx_venda_veiculo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_venda_veiculo ON public.venda USING btree (veiculo_id);


--
-- Name: idx_venda_veiculo_data; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_venda_veiculo_data ON public.venda USING btree (veiculo_id, data_venda DESC);


--
-- Name: idx_view_loja; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_view_loja ON public.veiculo_view USING btree (loja_id);


--
-- Name: idx_view_veiculo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_view_veiculo ON public.veiculo_view USING btree (veiculo_id);


--
-- Name: usuario_loja trg_usuario_loja_empresa; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_usuario_loja_empresa BEFORE INSERT OR UPDATE ON public.usuario_loja FOR EACH ROW EXECUTE FUNCTION public.validar_usuario_loja_empresa();


--
-- Name: veiculo trigger_busca_veiculo; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_busca_veiculo BEFORE INSERT OR UPDATE ON public.veiculo FOR EACH ROW EXECUTE FUNCTION public.atualizar_busca_veiculo();


--
-- Name: assinatura assinatura_empresa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assinatura
    ADD CONSTRAINT assinatura_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id);


--
-- Name: assinatura assinatura_plano_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assinatura
    ADD CONSTRAINT assinatura_plano_id_fkey FOREIGN KEY (plano_id) REFERENCES public.plano(id);


--
-- Name: avaliacao_loja avaliacao_loja_loja_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avaliacao_loja
    ADD CONSTRAINT avaliacao_loja_loja_id_fkey FOREIGN KEY (loja_id) REFERENCES public.loja(id);


--
-- Name: avaliacao_loja avaliacao_loja_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avaliacao_loja
    ADD CONSTRAINT avaliacao_loja_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: favorito favorito_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorito
    ADD CONSTRAINT favorito_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: favorito favorito_veiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorito
    ADD CONSTRAINT favorito_veiculo_id_fkey FOREIGN KEY (veiculo_id) REFERENCES public.veiculo(id);


--
-- Name: lead fk_lead_loja; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead
    ADD CONSTRAINT fk_lead_loja FOREIGN KEY (loja_id) REFERENCES public.loja(id);


--
-- Name: lead fk_lead_loja_empresa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead
    ADD CONSTRAINT fk_lead_loja_empresa FOREIGN KEY (loja_id, empresa_id) REFERENCES public.loja(id, empresa_id);


--
-- Name: veiculo_midia fk_midia_loja; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_midia
    ADD CONSTRAINT fk_midia_loja FOREIGN KEY (loja_id) REFERENCES public.loja(id);


--
-- Name: veiculo_midia fk_midia_veiculo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_midia
    ADD CONSTRAINT fk_midia_veiculo FOREIGN KEY (veiculo_id) REFERENCES public.veiculo(id);


--
-- Name: loja fk_plano; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loja
    ADD CONSTRAINT fk_plano FOREIGN KEY (plano_id) REFERENCES public.plano(id);


--
-- Name: veiculo fk_veiculo_loja_empresa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo
    ADD CONSTRAINT fk_veiculo_loja_empresa FOREIGN KEY (loja_id, empresa_id) REFERENCES public.loja(id, empresa_id);


--
-- Name: venda fk_venda_loja; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venda
    ADD CONSTRAINT fk_venda_loja FOREIGN KEY (loja_id) REFERENCES public.loja(id);


--
-- Name: venda fk_venda_loja_empresa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venda
    ADD CONSTRAINT fk_venda_loja_empresa FOREIGN KEY (loja_id, empresa_id) REFERENCES public.loja(id, empresa_id);


--
-- Name: veiculo_view fk_view_loja; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_view
    ADD CONSTRAINT fk_view_loja FOREIGN KEY (loja_id) REFERENCES public.loja(id);


--
-- Name: veiculo_view fk_view_veiculo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_view
    ADD CONSTRAINT fk_view_veiculo FOREIGN KEY (veiculo_id) REFERENCES public.veiculo(id);


--
-- Name: lead lead_veiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead
    ADD CONSTRAINT lead_veiculo_id_fkey FOREIGN KEY (veiculo_id) REFERENCES public.veiculo(id) ON DELETE CASCADE;


--
-- Name: loja loja_empresa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loja
    ADD CONSTRAINT loja_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id) ON DELETE CASCADE;


--
-- Name: loja loja_plano_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loja
    ADD CONSTRAINT loja_plano_id_fkey FOREIGN KEY (plano_id) REFERENCES public.plano(id);


--
-- Name: modelo modelo_marca_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modelo
    ADD CONSTRAINT modelo_marca_id_fkey FOREIGN KEY (marca_id) REFERENCES public.marca(id);


--
-- Name: role_permissao role_permissao_permissao_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissao
    ADD CONSTRAINT role_permissao_permissao_id_fkey FOREIGN KEY (permissao_id) REFERENCES public.permissoes(id) ON DELETE CASCADE;


--
-- Name: role_permissao role_permissao_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissao
    ADD CONSTRAINT role_permissao_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: usuario usuario_empresa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id);


--
-- Name: usuario_loja usuario_loja_loja_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_loja
    ADD CONSTRAINT usuario_loja_loja_id_fkey FOREIGN KEY (loja_id) REFERENCES public.loja(id) ON DELETE CASCADE;


--
-- Name: usuario_loja usuario_loja_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_loja
    ADD CONSTRAINT usuario_loja_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE CASCADE;


--
-- Name: usuario_role usuario_role_loja_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_role
    ADD CONSTRAINT usuario_role_loja_id_fkey FOREIGN KEY (loja_id) REFERENCES public.loja(id) ON DELETE CASCADE;


--
-- Name: usuario_role usuario_role_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_role
    ADD CONSTRAINT usuario_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: usuario_role usuario_role_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_role
    ADD CONSTRAINT usuario_role_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE CASCADE;


--
-- Name: veiculo_documento veiculo_documento_proprietario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_documento
    ADD CONSTRAINT veiculo_documento_proprietario_id_fkey FOREIGN KEY (proprietario_id) REFERENCES public.veiculo_proprietario(id) ON DELETE SET NULL;


--
-- Name: veiculo_documento veiculo_documento_veiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_documento
    ADD CONSTRAINT veiculo_documento_veiculo_id_fkey FOREIGN KEY (veiculo_id) REFERENCES public.veiculo(id) ON DELETE CASCADE;


--
-- Name: veiculo veiculo_empresa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo
    ADD CONSTRAINT veiculo_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id);


--
-- Name: veiculo_foto veiculo_foto_loja_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_foto
    ADD CONSTRAINT veiculo_foto_loja_id_fkey FOREIGN KEY (loja_id) REFERENCES public.loja(id);


--
-- Name: veiculo_foto veiculo_foto_veiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_foto
    ADD CONSTRAINT veiculo_foto_veiculo_id_fkey FOREIGN KEY (veiculo_id) REFERENCES public.veiculo(id);


--
-- Name: veiculo veiculo_loja_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo
    ADD CONSTRAINT veiculo_loja_id_fkey FOREIGN KEY (loja_id) REFERENCES public.loja(id);


--
-- Name: veiculo_opcional veiculo_opcional_opcional_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_opcional
    ADD CONSTRAINT veiculo_opcional_opcional_id_fkey FOREIGN KEY (opcional_id) REFERENCES public.opcional(id);


--
-- Name: veiculo_opcional veiculo_opcional_veiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_opcional
    ADD CONSTRAINT veiculo_opcional_veiculo_id_fkey FOREIGN KEY (veiculo_id) REFERENCES public.veiculo(id);


--
-- Name: veiculo_proprietario veiculo_proprietario_veiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veiculo_proprietario
    ADD CONSTRAINT veiculo_proprietario_veiculo_id_fkey FOREIGN KEY (veiculo_id) REFERENCES public.veiculo(id) ON DELETE CASCADE;


--
-- Name: venda_entrada venda_entrada_empresa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venda_entrada
    ADD CONSTRAINT venda_entrada_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id);


--
-- Name: venda_entrada venda_entrada_loja_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venda_entrada
    ADD CONSTRAINT venda_entrada_loja_id_fkey FOREIGN KEY (loja_id) REFERENCES public.loja(id);


--
-- Name: venda_entrada venda_entrada_venda_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venda_entrada
    ADD CONSTRAINT venda_entrada_venda_id_fkey FOREIGN KEY (venda_id) REFERENCES public.venda(id) ON DELETE CASCADE;


--
-- Name: versao versao_modelo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.versao
    ADD CONSTRAINT versao_modelo_id_fkey FOREIGN KEY (modelo_id) REFERENCES public.modelo(id);


--
-- PostgreSQL database dump complete
--

\unrestrict slgAsgMXZhFtoTun58GP7RDXf24tARThsJiJV6q68Obd9f1hHnfe2xhYXdqMU6G

