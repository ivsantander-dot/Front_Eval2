# ── ETAPA 1: instalar dependencias ───────────────
FROM python:3.11-slim AS builder
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt --target=/app/deps

# ── ETAPA 2: imagen final liviana ─────────────────
FROM python:3.11-slim AS runtime
WORKDIR /app

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

COPY --from=builder /app/deps /app/deps
COPY . .

RUN chown -R appuser:appgroup /app
USER appuser

ENV PYTHONPATH=/app/deps
ENV PORT=5000
ENV DEBUG=False

EXPOSE 5000

CMD ["python", "app.py"]