FROM node:20

WORKDIR /app

RUN npm install -g @boundaryml/baml@0.68.0

COPY --chown=1000:1000 baml_src/ ./baml_src

USER 1000

CMD baml-cli serve --preview --port 2024
