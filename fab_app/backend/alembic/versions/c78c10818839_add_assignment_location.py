"""add assignment location

Revision ID: c78c10818839
Revises: 0f9699289d02
Create Date: 2026-07-24 11:33:10.290100

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'c78c10818839'
down_revision: Union[str, Sequence[str], None] = '0f9699289d02'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.add_column('assignments', sa.Column('location', sa.String(), server_default='On Site', nullable=False))


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_column('assignments', 'location')
