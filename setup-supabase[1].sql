-- ============================================================================
-- Solar Organization — configuração do banco no Supabase
-- ============================================================================
-- Como usar:
-- 1. Crie um projeto gratuito em https://supabase.com
-- 2. No painel do projeto, vá em "SQL Editor" > "New query"
-- 3. Cole TODO este arquivo e clique em "Run" (uma única vez)
-- 4. Em "Settings" > "API", copie a "Project URL" e a chave "anon public"
-- 5. Cole esses dois valores no arquivo do site (SUPABASE_URL e SUPABASE_ANON_KEY)
-- ============================================================================

-- Tabelas: uma linha por usuário em cada tabela, guardando os dados como JSON.
-- Isso mantém a estrutura simples e funciona diretamente com o formato que o
-- site já usa (arrays de perfis / clientes / orçamentos).

create table if not exists perfis_faturamento (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists clientes (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists orcamentos (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

-- ============================================================================
-- Row Level Security: a parte que realmente garante o isolamento entre contas.
-- Com isso ativado, o banco de dados em si recusa qualquer tentativa de ler ou
-- escrever uma linha que não pertença ao usuário autenticado — mesmo que
-- alguém tente burlar o site e chamar a API do Supabase diretamente.
-- ============================================================================

alter table perfis_faturamento enable row level security;
alter table clientes enable row level security;
alter table orcamentos enable row level security;

-- perfis_faturamento
create policy "select_proprios_perfis" on perfis_faturamento
  for select using (auth.uid() = user_id);
create policy "insert_proprios_perfis" on perfis_faturamento
  for insert with check (auth.uid() = user_id);
create policy "update_proprios_perfis" on perfis_faturamento
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "delete_proprios_perfis" on perfis_faturamento
  for delete using (auth.uid() = user_id);

-- clientes
create policy "select_proprios_clientes" on clientes
  for select using (auth.uid() = user_id);
create policy "insert_proprios_clientes" on clientes
  for insert with check (auth.uid() = user_id);
create policy "update_proprios_clientes" on clientes
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "delete_proprios_clientes" on clientes
  for delete using (auth.uid() = user_id);

-- orcamentos
create policy "select_proprios_orcamentos" on orcamentos
  for select using (auth.uid() = user_id);
create policy "insert_proprios_orcamentos" on orcamentos
  for insert with check (auth.uid() = user_id);
create policy "update_proprios_orcamentos" on orcamentos
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "delete_proprios_orcamentos" on orcamentos
  for delete using (auth.uid() = user_id);

-- ============================================================================
-- Pronto. Depois de rodar este script:
-- - Cada novo usuário que criar conta no site começa com as tabelas vazias
--   (o próprio site cuida de popular os modelos padrão e 1 cliente de exemplo
--   no primeiro acesso).
-- - Nenhum usuário consegue ler ou alterar linhas de outro usuário, garantido
--   pelo banco de dados, não pelo código do site.
-- ============================================================================
