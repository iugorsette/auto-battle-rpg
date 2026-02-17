# The Kingdom Raetna
> Auto Battler RPG

<img src="assets/backgrounds/the-kingdom-raetna.png" alt="The Kingdom" width="100%" />

Jogo em Flutter + Flame com batalhas automáticas e habilidades ativas.

## Créditos e Lore
Todas as imagens foram geradas por IA pelo ChatGPT-5.2. Raetna é um anagrama de Renata (minha esposa) e Suigetto é um anagrama de iugorsette (meu nome). Em breve vou lançar a lore completa do jogo.

## Destaques
- Batalha em tempo real com telegraph, projéteis e efeitos visuais.
- Classes jogáveis: Cavaleiro, Mago e Arqueiro.
- Habilidades avançadas no nível 4 com ataques em área.
- Inimigos com padrões e fases (ex.: fúria abaixo de 50% de HP).
- Dano colorido por tipo e texto flutuante com animação.
- Sistema de níveis e XP com evolução de atributos.
- Loot pós-batalha com raridades e bônus.
- Log de combate e status (buffs/debuffs) em tela.
- Fundo procedural animado e UI estilizada.
- Música de introdução, efeitos por habilidade e controle de volume.

## Como Rodar
```bash
flutter pub get
flutter run -d linux
```

## Estrutura Principal
- `lib/game/` motor e componentes de batalha (Flame).
- `lib/domain/` dados de personagens, skills, progressão, loot e inimigos.
- `lib/ui/` telas, widgets e fluxo de navegação.
- `assets/characters/` sprites.
- `assets/backgrounds/` fundos (opcional).
- `assets/audio/` efeitos sonoros e músicas.
- `assets/audio/combo/` sons de habilidades e ataques.

## Documentação
- [Personagens e habilidades](docs/characters.md)
- [Monstros](docs/monsters.md)
- [Sistema de batalha](docs/battle.md)

## Fluxo de Jogo
1. Criar personagem (máximo 3).
2. Escolher personagem no roster.
3. Selecionar batalha pelo nível.
4. Evoluir com XP e loot.

## Notas
- Sprites podem ser substituídos em `assets/characters/`.
- Novos inimigos e habilidades podem ser adicionados em:
  - `lib/domain/battle/enemy_catalog.dart`
  - `lib/domain/skills/basic_skills.dart`
 - Ajustes de áudio ficam em `lib/game/sound/sound_manager.dart`.
