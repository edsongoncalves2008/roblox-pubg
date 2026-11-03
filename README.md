# Jungle Battlegrounds — Etapa 1

Base de desenvolvimento Roblox em Luau, com geometria original gerada por código. Não contém recursos extraídos de PUBG. O cenário é uma ilha tropical original, inspirada no gênero, sem reproduzir a geografia de Sanhok.

## Abrir no Roblox Studio

1. Abra `build/JungleBattlegrounds.rbxlx` pelo menu **File → Open from File**.
2. Pressione **Play**, não apenas Run, para criar o personagem e executar o cliente.
3. O terreno e os edifícios são gerados pelo servidor ao iniciar. Aguarde a geração.
4. Para testar combate multiplayer: **Test → Server & Clients**, selecione dois clientes e inicie. Reúna os jogadores no mesmo ponto do mapa; os nascimentos variam entre edifícios.
5. Para salvar o cenário gerado como edição permanente, será necessário um fluxo de edição no Studio; o arquivo entregue gera o mundo a cada sessão.

Alternativa: use Rojo com `default.project.json`. `ReplicatedStorage/Shared` recebe `src/shared`, `ServerScriptService/Game` recebe `src/server` e `StarterPlayer/StarterPlayerScripts/Game` recebe `src/client`. Nenhum plugin é necessário para abrir o `.rbxlx`.

## Gerar novamente

Execute na raiz do repositório:

```sh
python3 tools/build_place.py
python3 -m unittest discover -s tests -v
```

O gerador usa somente a biblioteca padrão do Python. O XML incorpora o código-fonte integral dos scripts. Execute novamente após qualquer alteração Luau.

## Código implementado

- Ilha de 1536 studs, Terrain de grama/areia/água, relevo, iluminação e atmosfera tropical. Escala inicial reduzida, não 4 × 4 km.
- Bootcamp e três áreas originais: Paradise Grove, River Village e Temple Ruins. Nesta entrega, usam a mesma família de edifícios; não representam ainda vila fluvial nem templo detalhado.
- Dezesseis construções com interiores, vãos de portas e janelas, cobertura, escadas externas e telhados acessíveis; palmeiras de geometria simples. Portas não têm folhas móveis.
- Andar, sprint, velocidade agachada e deslocamento de câmera; TPS sobre o ombro, FPS e zoom ADS. Agachar ainda não reduz a cápsula de colisão nem tem animação própria.
- M416 e AKM com modelos básicos originais soldados à mão, disparo automático, recuo de câmera, dispersão, recarga e munição finita por arma.
- Trajetória balística no servidor com raycasts segmentados, gravidade, alcance, dano de cabeça, HP, eliminações, kill feed e respawn padrão.
- Validação de formato/vetores, origem próxima à cabeça, obstrução de câmera, cadência, munição e limite de remotes/projéteis. Isso não constitui proteção completa contra cheats de movimento ou aimbot.
- HUD e botões de toque; seis alvos estáticos de treino em Bootcamp, próximos de `(0,18,-105)`. Não são bots. Permanecem eliminados até reiniciar a sessão.
- Streaming habilitado no arquivo e na configuração Rojo. Nenhuma meta de FPS foi medida.

## Controles

| Ação | Controle |
|---|---|
| Mover / pular | WASD / espaço, controles nativos de toque |
| Disparar / mirar | Mouse esquerdo / direito |
| Correr / agachar | Shift / C |
| TPS/FPS | V |
| Recarregar | R |
| M416 / AKM | 1 / 2 |

Em dispositivos móveis, os botões mostram os nomes das ações em inglês.

## Validação e critérios no Studio

A validação em nuvem cobre sintaxe com o compilador oficial Luau e integridade do arquivo XML. **Não foi executado Roblox Studio neste ambiente.** A jogabilidade e a API Roblox precisam do seguinte teste antes de considerar a Etapa 1 concluída:

- Iniciar Play sem erros no Output; conferir terreno, interiores, escadas e colisão das árvores.
- Testar câmera TPS/FPS, ADS e disparo nas duas perspectivas, inclusive junto de paredes; o servidor deve rejeitar tiro com câmera obstruída.
- Disparar em alvo/cabeça, esvaziar carregador, recarregar, trocar armas e confirmar que a troca não repõe munição.
- Com dois clientes: observar arma do outro jogador, dano, eliminação, atualização do feed e respawn.
- Conferir HUD e botões no Device Emulator; avaliar gestos e mira em aparelho real.
- Medir memória, tempo de geração, streaming e FPS antes de aumentar escala ou população.

## Próximas etapas e limites

Etapa 1 implementada para avaliação, ainda sem validação de execução no Studio. Não há animações próprias, sons licenciados, postura prone, lean, vaulting, queda, anti-teleporte, redução de colisão ao agachar ou arte final. O terreno e os modelos têm acabamento inicial. Não representa um jogo completo ou publicável.

Etapas 2–5 pendentes: lobby/partida, avião, paraquedas, zona, loot/inventário, equipes, veículos, cura, acessórios, mapa completo, bots, estatísticas e polimento. Avançar após verificar e corrigir a Etapa 1 no Studio, conforme os critérios acima.
