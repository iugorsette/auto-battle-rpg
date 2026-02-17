# Batalha

## Fluxo Geral
- O combate é automático, alternando entre jogador e inimigos.
- Há um intervalo curto entre ataques (`turn gap`) para dar ritmo ao combate.
- O jogador pode ativar skills manualmente pela UI.

## Ataques Básicos
- Ataque tem `wind-up` antes de acertar o alvo.
- Personagens corpo a corpo fazem um avanço (lunge) no início do ataque.
- Arqueiros disparam projéteis físicos; magos disparam projéteis mágicos.

## Alvos
- O jogador sempre ataca o primeiro inimigo vivo.
- Inimigos atacam o jogador em fila (round-robin).

## Dano
- Fórmula base: `dano = valor - defesa`.
- Se o dano bruto for `<= 0`, o ataque vira `Miss`.
- Dano mínimo aplicado: 1.

## Mana e Cooldowns
- Cooldowns de skills diminuem a cada 1s.
- Mana regenera a cada 1s.

## Status
- Status têm duração em ticks (1 tick = 1s).
- Exemplo de status: `burn`, `freeze`, `poison`, `hex`, `warcry`.

## Evolução no Combate
- Ao vencer, o personagem ganha XP e loot.
- Ao subir de nível: HP +15, ATK +4, DEF +2, SPD +1 a cada 3 níveis.

## Dicas de Balanceamento
- SPD reduz o tempo entre ataques.
- Skills de área são fortes contra múltiplos inimigos.
