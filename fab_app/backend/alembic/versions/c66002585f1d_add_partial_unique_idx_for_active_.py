"""add_partial_unique_idx_for_active_assignments

Revision ID: c66002585f1d
Revises: 47b7e825d86a
Create Date: 2026-08-18 12:00:59.917243

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'c66002585f1d'
down_revision: Union[str, Sequence[str], None] = '47b7e825d86a'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    bind = op.get_bind()
    dialect = bind.dialect.name
    if dialect == "postgresql":
        op.create_index(
            'idx_active_assignment_machine',
            'assignments',
            ['machine_id'],
            unique=True,
            postgresql_where=sa.text('returned_at IS NULL')
        )
    elif dialect == "sqlite":
        op.create_index(
            'idx_active_assignment_machine',
            'assignments',
            ['machine_id'],
            unique=True,
            sqlite_where=sa.text('returned_at IS NULL')
        )
    else:
        # Fallback to standard unique index if other dialect
        op.create_index(
            'idx_active_assignment_machine',
            'assignments',
            ['machine_id'],
            unique=True
        )


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index('idx_active_assignment_machine', table_name='assignments')
