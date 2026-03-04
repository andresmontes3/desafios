
/*Tables Creation*/

create table Parts(
	PartID int identity (1,1),
	PartName varchar(max),
	primary key (PartID)
)

create table BillOfMaterials(
	BillID int identity (1,1),
	ParentPartID int,
	ChildPartID int,
	QuantityPerParent int,
	primary key (BillID),
	foreign key (ParentPartID) references Parts(PartID),
	foreign key (ChildPartID) references Parts(PartID)
)

/*Inserting Parts*/
insert into Parts(PartName)
values ('Personal Computer')
declare @PCPartID int = @@identity

insert into Parts(PartName)
values ('Power Supply')
declare @PSUPartID int = @@identity

insert into Parts(PartName)
values ('Case')
declare @CasePartID int = @@identity

insert into Parts(PartName)
values ('Motherboard')
declare @MBPartID int = @@identity

insert into Parts(PartName)
values ('CPU')
declare @CPUPartID int = @@identity

insert into Parts(PartName)
values ('RAM Stick')
declare @RAMPartID int = @@identity

/*Parts Parent-Child Relations*/
insert into BillOfMaterials(ParentPartID, ChildPartID, QuantityPerParent)
values (@PCPartID, @PSUPartID, 1)
insert into BillOfMaterials(ParentPartID, ChildPartID, QuantityPerParent)
values (@PCPartID, @CasePartID, 1)
insert into BillOfMaterials(ParentPartID, ChildPartID, QuantityPerParent)
values (@PCPartID, @MBPartID, 1)

insert into BillOfMaterials(ParentPartID, ChildPartID, QuantityPerParent)
values (@MBPartID, @CPUPartID, 1)
insert into BillOfMaterials(ParentPartID, ChildPartID, QuantityPerParent)
values (@MBPartID, @RAMPartID, 2)

/*Setting PC Quantity as 5*/
declare @QuantityPCs int = 5

select Component, sum(QuantityPerParent) * @QuantityPCs as Quantity
from
(select Parent.PartName as FinalProduct,--Level 1
	Child1.PartName as Component,
	BOM1.QuantityPerParent as QuantityPerParent
from Parts as Parent
inner join BillOfMaterials as BOM1
	on Parent.PartID = BOM1.ParentPartID
inner join Parts as Child1 
	on BOM1.ChildPartID = Child1.PartID
where not exists( --Checks the first level is not child of another Part
	select 1
	from BillOfMaterials
	where ChildPartID = Parent.PartID
)
and Parent.PartName = 'Personal Computer'

union all select Parent.PartName as FinalProduct,--Level 2
	Child2.PartName as Component,
	BOM1.QuantityPerParent * BOM2.QuantityPerParent as QuantityPerParent
from Parts as Parent
inner join BillOfMaterials as BOM1
	on Parent.PartID = BOM1.ParentPartID 
inner join Parts as Child1
	on BOM1.ChildPartID = Child1.PartID
inner join BillOfMaterials as BOM2 
	ON Child1.PartID = BOM2.ParentPartID 
inner join Parts as Child2
	ON BOM2.ChildPartID = Child2.PartID
where Parent.PartName = 'Personal Computer'

union all select Parent.PartName as FinalProduct,--Level 3
	Child3.PartName as Component,
	BOM1.QuantityPerParent * BOM2.QuantityPerParent * BOM3.QuantityPerParent as QuantityPerParent
from Parts as Parent
inner join BillOfMaterials as BOM1
	on Parent.PartID = BOM1.ParentPartID 
inner join Parts as Child1
	on BOM1.ChildPartID = Child1.PartID
inner join BillOfMaterials as BOM2 
	on Child1.PartID = BOM2.ParentPartID 
inner join Parts as Child2
	on BOM2.ChildPartID = Child2.PartID
inner join BillOfMaterials as BOM3 
	on Child2.PartID = BOM3.ParentPartID 
inner join Parts as Child3
	on BOM3.ChildPartID = Child3.PartID
where Parent.PartName = 'Personal Computer'
) as BOMLevels
group by Component

drop table BillOfMaterials, Parts
