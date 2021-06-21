from dataclasses import dataclass

@dataclass
class LotDefinition:
    origin: tuple
    name: str = None
    
    
site_def = LotDefinition(origin=(1,2,3))
print(f"Origin: {site_def.origin}")
print(f"{site_def}")