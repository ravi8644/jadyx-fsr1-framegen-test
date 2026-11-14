# Jadyx para Xbox

Emulador de Nintendo Switch para Xbox Series X|S em Modo de Desenvolvedor. Esta branch prepara a versão experimental 0.4.0.1 sobre o source oficial 0.4.0.0.

## 0.4.0.1

- FSR 1 e geração de quadros podem ser ativados juntos, inclusive em saída 4K.
- Modo RAM Saver e presets gráficos por jogo, com opção Personalizado.
- `output_cap` pode limitar a saída a 1440p ou 1080p para reduzir buffers de tela; `auto` aplica 1440p somente com FSR e geração de quadros ativos.
- HUD com memória do app, estado e espaço usado pelo Permafrost, percentis de frame e FPS do jogo separado do apresentado.
- Memory Ledger estima os recursos da cadeia de apresentação, além das demais categorias de memória rastreadas.

O AppX é uma compilação de teste, assinada com certificado temporário para Dev Mode. O artefato inclui o certificado e a dependência VCLibs; pode ser necessário instalar o certificado no console. O source completo está em `jadyx-0.4.0.1-merged-source.zip`. O desempenho e o consumo variam por jogo e ainda precisam ser avaliados no Xbox. Jogos, firmware e chaves não são incluídos.
