# Compatibilidade e uso

A mesma pasta `escrever-como-bruno/` contém as instruções e as referências para os três agentes. Copie a pasta completa, preservando `SKILL.md` e `references/`. O arquivo `agents/openai.yaml` é metadado de interface do Codex; o funcionamento da escrita não depende dele.

## Claude Code e OpenCode

Uma instalação compartilhada pode ficar em `~/.claude/skills/escrever-como-bruno/` para uso pessoal, ou `.claude/skills/escrever-como-bruno/` no projeto. Claude Code reconhece esses caminhos, e OpenCode também os consulta como fontes de compatibilidade. Fontes: [Claude Code — skills](https://code.claude.com/docs/en/skills), [OpenCode — skills](https://opencode.ai/docs/skills/).

| Agente | Caminho pessoal alternativo ou nativo | Uso explícito |
| --- | --- | --- |
| Claude Code | `~/.claude/skills/escrever-como-bruno/SKILL.md` | `/escrever-como-bruno` seguido do pedido |
| OpenCode | `~/.config/opencode/skills/escrever-como-bruno/SKILL.md` | Mencione `@escrever-como-bruno` no pedido |

Os caminhos e a invocação acima seguem as documentações oficiais de [Claude Code](https://code.claude.com/docs/en/skills) e [OpenCode](https://opencode.ai/docs/skills/), consultadas em 11 de novembro de 2026. Evite cópias divergentes com o mesmo nome em várias fontes.

## Codex

Use a mesma pasta no diretório de skills do seu ambiente Codex e invoque `$escrever-como-bruno`. `agents/openai.yaml` mantém o nome de exibição e o pedido inicial sugerido.

## Limites da portabilidade

O corpo da skill usa Markdown, frontmatter com `name` e `description` e referências relativas. Não exige comandos, hooks, MCPs, modelos específicos ou ferramentas exclusivas de um agente. A compatibilidade foi conferida pela estrutura do pacote e pelas documentações; não foi feito um teste de geração em sessões de Claude Code e OpenCode.
