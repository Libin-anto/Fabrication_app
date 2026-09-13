"""make box_id and machine_number optional

Revision ID: 54af5e8b8c96
Revises: c66002585f1d
Create Date: 2026-09-13 20:17:05.655073

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '54af5e8b8c96'
down_revision: Union[str, Sequence[str], None] = 'c66002585f1d'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Postgres specific schema changes
    # 1. Drop strict FK and make box_id nullable
    op.execute('ALTER TABLE workers DROP CONSTRAINT IF EXISTS workers_box_id_fkey CASCADE')
    op.execute('ALTER TABLE workers ALTER COLUMN box_id DROP NOT NULL')
    
    # 2. Add floor column to workers
    op.execute('ALTER TABLE workers ADD COLUMN IF NOT EXISTS floor VARCHAR')
    
    # 3. Make machine_number nullable
    op.execute('ALTER TABLE machines ALTER COLUMN machine_number DROP NOT NULL')


def downgrade() -> None:
    pass
