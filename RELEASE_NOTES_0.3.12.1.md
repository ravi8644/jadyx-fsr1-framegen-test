## Jadyx Xbox 0.3.12.1 — build experimental

Baseado no source oficial 0.3.12.0; a identidade do pacote foi elevada para 0.3.12.1 para permitir a instalação como atualização da versão anterior.

- FSR 1 e Frame Generation podem ficar ativos ao mesmo tempo. O FSR mantém a saída na resolução da tela, e os dois controles podem ser ajustados no menu rápido durante o jogo.
- Inclui opções gráficas por jogo para o modo ASTC, troca de memória do jogo e ASTC opaco em BC3. Essas opções são aplicadas no próximo início do jogo.
- Reduz alocações temporárias por quadro no compositor D3D12 e libera os buffers de trabalho ASTC (até cerca de 40 MiB) em pressão extrema de memória, sem reduzir a qualidade da imagem.
- O cache PSO do driver foi desativado nesta build por causa do crash relatado no Xbox. O cache de shaders próprio do Jadyx e a compilação assíncrona continuam disponíveis.

É uma compilação de teste, não uma versão oficial do projeto. As alterações de memória não garantem ganho de FPS; o resultado precisa ser testado no console e varia por jogo. O AppX é assinado com certificado de teste e requer a dependência VCLibs no Xbox Dev Mode.
